// lib/utils/ble_listening.dart (ou équivalent contrôleur BLE)

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:a4_iot/presentation/controllers/users.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

const String SERVICE_UUID = "12345678-1234-1234-1234-1234567890ab";
const String CHARACTERISTIC_WRITE_UUID = "abcd1234-1234-1234-1234-abcdefabcdef";
const String CHARACTERISTIC_STATUS_UUID =
    "12345678-1234-1234-1234-123456789abc";
const String CHARACTERISTIC_NEXT_CLASS_UUID =
    "12345678-1234-1234-1234-123456789abd";

final isConnectedProvider = StateProvider<bool>((ref) => false);
final connectedDeviceProvider = StateProvider<BluetoothDevice?>((ref) => null);

final statusDataProvider = StateProvider<String>((ref) => '');
final nextClassDataProvider = StateProvider<String>((ref) => '');

final bleControllerProvider = Provider<BleController>((ref) {
  return BleController(ref);
});

class BleController {
  final Ref ref;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _statusSub;
  StreamSubscription<List<int>>? _nextClassSub;

  BleController(this.ref);

  Future<void> startAutoConnect(String targetName) async {
    bool permsGranted = await _requestPermissions();
    if (!permsGranted) {
      print("Permissions manquantes pour le BLE");
      return;
    }

    if (ref.read(isConnectedProvider)) {
      print("Déjà connecté");
      return;
    }

    print("Recherche automatique de '$targetName'...");

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.platformName == targetName) {
          print(
            "Cible trouvée: ${r.device.platformName} (${r.device.remoteId})",
          );

          await stopScan();
          await connectToDevice(r.device);
          break;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        withNames: [targetName],
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      print("Erreur scan: $e");
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
    } catch (e) {
      print("Erreur lors de l'arrêt du scan: $e");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print("Tentative de connexion...");

      await stopScan();
      await Future.delayed(const Duration(milliseconds: 200));

      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 10),
      );

      ref.read(isConnectedProvider.notifier).state = true;
      ref.read(connectedDeviceProvider.notifier).state = device;
      print("CONNECTÉ à ${device.platformName} !");

      await _setupNotifications(device);

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          print("Perte de connexion");
          _cleanupStreams();
          ref.read(isConnectedProvider.notifier).state = false;
          ref.read(connectedDeviceProvider.notifier).state = null;
        }
      });
    } catch (e) {
      print("Échec connexion: $e");
      ref.read(isConnectedProvider.notifier).state = false;
      try {
        await device.disconnect();
      } catch (_) {}
    }
  }

  Future<void> _setupNotifications(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      BluetoothCharacteristic? statusChar;
      BluetoothCharacteristic? nextClassChar;

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            SERVICE_UUID.toLowerCase()) {
          for (var c in service.characteristics) {
            final uuid = c.uuid.toString().toLowerCase();
            if (uuid == CHARACTERISTIC_STATUS_UUID.toLowerCase()) {
              statusChar = c;
            } else if (uuid == CHARACTERISTIC_NEXT_CLASS_UUID.toLowerCase()) {
              nextClassChar = c;
            }
          }
        }
      }

      if (statusChar != null) {
        await statusChar.setNotifyValue(true);
        _statusSub = statusChar.lastValueStream.listen((value) {
          final json = utf8.decode(value);
          print("STATUS BLE: $json");
          ref.read(statusDataProvider.notifier).state = json;
        });
        device.cancelWhenDisconnected(_statusSub!);
      } else {
        print("Status characteristic non trouvée");
      }

      if (nextClassChar != null) {
        await nextClassChar.setNotifyValue(true);
        _nextClassSub = nextClassChar.lastValueStream.listen((value) {
          final json = utf8.decode(value);
          print("NEXT CLASS BLE: $json");
          ref.read(nextClassDataProvider.notifier).state = json;
        });
        device.cancelWhenDisconnected(_nextClassSub!);
      } else {
        print("NextClass characteristic non trouvée");
      }
    } catch (e) {
      print("Erreur _setupNotifications: $e");
    }
  }

  void _cleanupStreams() {
    _statusSub?.cancel();
    _nextClassSub?.cancel();
    _connectionSubscription?.cancel();
    _statusSub = null;
    _nextClassSub = null;
    _connectionSubscription = null;
  }

  Future<void> disconnect() async {
    final device = ref.read(connectedDeviceProvider);
    if (device != null) {
      await device.disconnect();
      _cleanupStreams();
      ref.read(isConnectedProvider.notifier).state = false;
      ref.read(connectedDeviceProvider.notifier).state = null;
      print("Déconnecté manuellement");
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      return statuses.values.every((s) => s.isGranted);
    }
    return true;
  }

  Future<void> sendOpenCommand() async {
    final device = ref.read(connectedDeviceProvider);
    final user = ref.read(usersProvider).asData?.value;
    if (device == null) {
      print("Pas d'appareil connecté");
      return;
    }

    try {
      print("Recherche du service et de la caractéristique d'écriture...");

      final services = await device.discoverServices();
      BluetoothCharacteristic? targetChar;

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            SERVICE_UUID.toLowerCase()) {
          for (var c in service.characteristics) {
            if (c.uuid.toString().toLowerCase() ==
                CHARACTERISTIC_WRITE_UUID.toLowerCase()) {
              targetChar = c;
              break;
            }
          }
        }
      }

      if (targetChar != null) {
        print("Préparation de la commande JSON...");
        print("User badge ID: ${user?.badgeId}");
        final now = DateTime.now();
        final formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:00").format(now);

        final command = {
          "action": "open",
          "badge_id": user?.badgeId ?? "TEST_USER",
          "timestamp": formattedDate,
        };

        final jsonString = jsonEncode(command);
        print("Envoi: $jsonString");

        final bytes = utf8.encode(jsonString);
        await targetChar.write(bytes, withoutResponse: false);

        print("Commande envoyée avec succès !");
      } else {
        print("Caractéristique d'écriture introuvable.");
        print("Attendu Service: $SERVICE_UUID");
        print("Attendu Char: $CHARACTERISTIC_WRITE_UUID");
        for (var s in services) {
          print("- Service: ${s.uuid}");
          for (var c in s.characteristics) {
            print("  - Char: ${c.uuid}");
          }
        }
      }
    } catch (e) {
      print("Erreur lors de l'envoi: $e");
    }
  }
}
