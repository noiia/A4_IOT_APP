import 'package:flutter/material.dart';
import 'package:a4_iot/core/config/app_theme.dart';

/// Badge de notification avec compteur
class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.notifications_outlined,
              color: count > 0 ? AppTheme.primaryColor : AppTheme.textMuted,
              size: 28,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.errorColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Badge simple pour les indicateurs
class SimpleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isSmall;

  const SimpleBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: isSmall ? 12 : 14,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge numérique pour les compteurs
class CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  final String? label;
  final bool isSmall;

  const CountBadge({
    super.key,
    required this.count,
    required this.color,
    this.label,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (label != null) ...[
            SizedBox(width: isSmall ? 4 : 6),
            Text(
              label!,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 11 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
