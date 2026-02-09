import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:a4_iot/presentation/controllers/users.dart';
import 'package:a4_iot/presentation/views/home_view.dart';
import 'package:a4_iot/presentation/views/login_view.dart';
import 'package:a4_iot/presentation/views/prom_view.dart';
import 'package:a4_iot/utils/ble_listening.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

Future<bool> hasInternet() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [HomeView(), PromsPageView()];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("🏁 Initialisation : Recherche auto de 'MyDoorLock'...");
      ref.read(bleControllerProvider).startAutoConnect('MyDoorLock');
    });
  }

  Future<void> _logout(BuildContext context) async {
    await ref.read(bleControllerProvider).disconnect();

    await Supabase.instance.client.auth.signOut();
    ref.invalidate(usersProvider);
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écoute l'état de connexion pour mettre à jour l'UI
    final isConnected = ref.watch(isConnectedProvider);
    final controller = ref.read(bleControllerProvider);
    final statusJson = ref.watch(statusDataProvider);
    final nextClassJson = ref.watch(nextClassDataProvider);
    print("UI STATUS: $statusJson");
    print("UI NEXT CLASS: $nextClassJson");
    return Scaffold(
      // Barre optionnelle pour confirmer la connexion visuellement
      appBar: isConnected
          ? AppBar(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_connected, size: 20),
                  SizedBox(width: 8),
                  Text("Porte Connectée", style: TextStyle(fontSize: 16)),
                ],
              ),
              backgroundColor: Colors.greenAccent.withOpacity(0.8),
              centerTitle: true,
              toolbarHeight: 40,
              automaticallyImplyLeading: false, // Pas de flèche retour
            )
          : null,

      body: Stack(
        children: [
          // Les pages de l'application (Home / Proms)
          _pages[_currentIndex],

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: "ble_action_fab",
              onPressed: () async {
                if (isConnected) {
                  await controller.sendOpenCommand();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Ouverture..."),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // --- CAS 2: DÉCONNECTÉ -> LANCER SCAN ---
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Recherche de la porte..."),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                  controller.startAutoConnect('MyDoorLock');
                }
              },

              backgroundColor: isConnected ? Colors.orange : Colors.blueAccent,
              // ICÔNE : Cadenas ouvert ou Bluetooth
              icon: Icon(
                isConnected ? Icons.lock_open : Icons.bluetooth_searching,
                size: 28,
              ),
              label: Text(
                isConnected ? "OUVRIR PORTE" : "CONNECTER",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 2) {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Déconnexion'),
                content: const Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              await _logout(context);
            }
          } else {
            // Navigation normale
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Promo"),
          BottomNavigationBarItem(
            icon: Icon(Icons.output, color: Colors.red),
            label: "Déconnexion",
          ),
        ],
      ),
    );
  }
}
