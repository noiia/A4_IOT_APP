import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/presentation/controllers/admin.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Vue de l'historique de présence d'un étudiant
class StudentHistoryView extends ConsumerWidget {
  final String studentId;
  final String studentName;

  const StudentHistoryView({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(studentAttendanceHistoryProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de présence'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentAttendanceHistoryProvider(studentId));
        },
        child: historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return EmptyState(
                icon: Icons.history,
                title: 'Aucun historique',
                subtitle:
                    'Aucune donnée de présence pour $studentName',
              );
            }

            // Calculer les statistiques
            final totalCourses = history.length;
            final presentCount = history
                .where((h) => h.status == AttendanceStatus.present)
                .length;
            final lateCount =
                history.where((h) => h.status == AttendanceStatus.late).length;
            final attendanceRate = totalCourses > 0
                ? ((presentCount + lateCount) / totalCourses * 100)
                : 0.0;

            Color rateColor;
            if (attendanceRate >= 80) {
              rateColor = AppTheme.successColor;
            } else if (attendanceRate >= 60) {
              rateColor = AppTheme.warningColor;
            } else {
              rateColor = AppTheme.errorColor;
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Carte de profil étudiant
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: AppTheme.borderRadiusLarge,
                    boxShadow: AppTheme.elevatedShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (history.first.studentPromo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          history.first.studentPromo!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistiques
                Text(
                  'Statistiques globales',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    _StatBox(
                      label: 'Taux de présence',
                      value: '${attendanceRate.toStringAsFixed(0)}%',
                      color: rateColor,
                      isHighlight: true,
                    ),
                    _StatBox(
                      label: 'Total cours',
                      value: '$totalCourses',
                      color: AppTheme.primaryColor,
                    ),
                    _StatBox(
                      label: 'Présents',
                      value: '$presentCount',
                      color: AppTheme.successColor,
                    ),
                    _StatBox(
                      label: 'Retards',
                      value: '$lateCount',
                      color: AppTheme.warningColor,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Historique détaillé
                Text(
                  'Historique détaillé',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 16),

                ...history.map((attendance) {
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

                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                attendance.courseName ?? 'Cours inconnu',
                                style: AppTheme.titleMedium,
                              ),
                            ),
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
                        if (attendance.checkInTime != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(attendance.checkInTime!),
                                style: AppTheme.bodyMedium,
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm')
                                    .format(attendance.checkInTime!),
                                style: AppTheme.bodyMedium,
                              ),
                              if (attendance.delayMinutes != null &&
                                  attendance.delayMinutes! > 0) ...[
                                const SizedBox(width: 16),
                                Container(
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.warningColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Erreur de chargement',
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de box statistique
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlight;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isHighlight
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isHighlight ? null : Colors.white,
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: isHighlight
            ? AppTheme.coloredShadow(color)
            : AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? Colors.white : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
