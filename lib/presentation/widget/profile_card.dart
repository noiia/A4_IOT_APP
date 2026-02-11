// lib/presentation/widget/profile_card.dart

import 'package:flutter/material.dart';
import 'dart:convert';

class ProfileCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String status;
  final String proms;
  final String campus;
  final String lastPointing;
  final String? bleStatusJson;
  final String avatarUrl;

  const ProfileCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.proms,
    required this.campus,
    required this.lastPointing,
    this.bleStatusJson,
    required this.avatarUrl,
  });

  Map<String, dynamic>? get _parsedBleStatus {
    if (bleStatusJson == null || bleStatusJson!.isEmpty) return null;
    try {
      return jsonDecode(bleStatusJson!);
    } catch (_) {
      return null;
    }
  }

  String get _displayStatus {
    final bleStatus = _parsedBleStatus;

    if (bleStatus != null) {
      switch (bleStatus['status']) {
        case 'checking_access':
          return 'Vérification en cours...';
        case 'not_authorized':
          return 'Accès refusé';
        case 'access_granted':
          return 'Accès autorisé';
        case 'door_opening':
          return 'Porte s\'ouvre';
        case 'door_closed':
          return 'Porte fermée';
        case 'connected':
          return 'Connecté';
        case 'ready':
          return 'Prêt';
        default:
          return status;
      }
    }

    return '$status - $lastPointing';
  }

  Color get _statusColor {
    final bleStatus = _parsedBleStatus?['status'];
    switch (bleStatus) {
      case 'access_granted':
      case 'connected':
      case 'ready':
        return Colors.green;
      case 'door_opening':
        return Colors.orange;
      case 'door_closed':
        return Colors.blue;
      case 'checking_access':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    final bleStatus = _parsedBleStatus?['status'];
    switch (bleStatus) {
      case 'door_opening':
      case 'door_closed':
        return Icons.door_front_door;
      case 'access_granted':
        return Icons.check_circle;
      case 'checking_access':
        return Icons.hourglass_empty;
      case 'connected':
        return Icons.bluetooth_connected;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                if (_parsedBleStatus != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_statusIcon, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "$firstName $lastName",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon, size: 18, color: _statusColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _displayStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$proms - $campus",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
