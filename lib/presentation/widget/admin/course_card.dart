import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Carte de cours pour l'admin
class CourseCard extends StatelessWidget {
  final AdminCourse course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOngoing = now.isAfter(course.startTime) && now.isBefore(course.endTime);
    final isPast = now.isAfter(course.endTime);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOngoing) {
      statusColor = AppTheme.successColor;
      statusText = 'En cours';
      statusIcon = Icons.play_circle_filled;
    } else if (isPast) {
      statusColor = AppTheme.textMuted;
      statusText = 'Terminé';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppTheme.primaryColor;
      statusText = 'À venir';
      statusIcon = Icons.schedule;
    }

    final attendanceRate = course.attendanceRate;
    Color attendanceColor;
    if (attendanceRate >= 80) {
      attendanceColor = AppTheme.successColor;
    } else if (attendanceRate >= 60) {
      attendanceColor = AppTheme.warningColor;
    } else {
      attendanceColor = AppTheme.errorColor;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadiusLarge,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.borderRadiusLarge,
          boxShadow: AppTheme.cardShadow,
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.courseName,
                      style: AppTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Horaires
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('HH:mm').format(course.startTime)} - ${DateFormat('HH:mm').format(course.endTime)}',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Salle
              Row(
                children: [
                  Icon(
                    Icons.room,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    course.roomName,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Promo
              Row(
                children: [
                  Icon(
                    Icons.groups,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    course.promoName,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              const Divider(),
              const SizedBox(height: 12),
              
              // Statistiques de présence
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${course.presentStudents}/${course.totalStudents}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'présents',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: attendanceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: attendanceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${attendanceRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: attendanceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte compacte de cours pour liste
class CompactCourseCard extends StatelessWidget {
  final AdminCourse course;
  final VoidCallback? onTap;

  const CompactCourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: AppTheme.borderRadiusMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH').format(course.startTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              DateFormat('mm').format(course.startTime),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
      title: Text(
        course.courseName,
        style: AppTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${course.roomName} • ${course.promoName}',
        style: AppTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${course.presentStudents}/${course.totalStudents}',
            style: AppTheme.titleMedium,
          ),
          Text(
            '${course.attendanceRate.toStringAsFixed(0)}%',
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
