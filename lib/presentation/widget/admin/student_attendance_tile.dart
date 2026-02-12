import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Tile d'affichage de présence d'étudiant
class StudentAttendanceTile extends StatelessWidget {
  final StudentAttendance attendance;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StudentAttendanceTile({
    super.key,
    required this.attendance,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (attendance.status) {
      case AttendanceStatus.present:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Présent';
        break;
      case AttendanceStatus.late:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        statusText = 'En retard';
        break;
      case AttendanceStatus.absent:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        statusText = 'Absent';
        break;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.borderRadiusLarge,
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Infos étudiant
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.studentName,
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (attendance.studentPromo != null) ...[
                        Text(
                          attendance.studentPromo!,
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          attendance.studentEmail,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (attendance.checkInTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(attendance.checkInTime!),
                          style: AppTheme.bodySmall,
                        ),
                        if (attendance.delayMinutes != null &&
                            attendance.delayMinutes! > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(+${attendance.delayMinutes} min)',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Badge de statut
            if (trailing != null)
              trailing!
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Variante compacte pour liste dense
class CompactStudentAttendanceTile extends StatelessWidget {
  final StudentAttendance attendance;
  final VoidCallback? onTap;

  const CompactStudentAttendanceTile({
    super.key,
    required this.attendance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (attendance.status) {
      case AttendanceStatus.present:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.late:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        break;
      case AttendanceStatus.absent:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
    }

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.1),
        child: Icon(
          statusIcon,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        attendance.studentName,
        style: AppTheme.bodyLarge,
      ),
      subtitle: attendance.checkInTime != null
          ? Text(
              DateFormat('HH:mm').format(attendance.checkInTime!),
              style: AppTheme.bodySmall,
            )
          : null,
      trailing: attendance.delayMinutes != null && attendance.delayMinutes! > 0
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${attendance.delayMinutes} min',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warningColor,
                ),
              ),
            )
          : null,
    );
  }
}

/// Tile avec actions de modification
class EditableStudentAttendanceTile extends StatelessWidget {
  final StudentAttendance attendance;
  final VoidCallback? onMarkPresent;
  final VoidCallback? onMarkAbsent;
  final VoidCallback? onMarkLate;

  const EditableStudentAttendanceTile({
    super.key,
    required this.attendance,
    this.onMarkPresent,
    this.onMarkAbsent,
    this.onMarkLate,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (attendance.status) {
      case AttendanceStatus.present:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.late:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        break;
      case AttendanceStatus.absent:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderRadiusLarge,
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            radius: 20,
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.studentName,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (attendance.studentPromo != null)
                  Text(
                    attendance.studentPromo!,
                    style: AppTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onMarkPresent,
                icon: Icon(
                  Icons.check_circle,
                  color: attendance.status == AttendanceStatus.present
                      ? AppTheme.successColor
                      : AppTheme.textMuted,
                ),
                tooltip: 'Présent',
                iconSize: 24,
              ),
              IconButton(
                onPressed: onMarkAbsent,
                icon: Icon(
                  Icons.cancel,
                  color: attendance.status == AttendanceStatus.absent
                      ? AppTheme.errorColor
                      : AppTheme.textMuted,
                ),
                tooltip: 'Absent',
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
