import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/presentation/controllers/admin.dart';
import 'package:a4_iot/presentation/widget/admin/student_attendance_tile.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Vue de détail d'un cours avec gestion des présences
class CourseDetailView extends ConsumerWidget {
  final String courseId;

  const CourseDetailView({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseStatsAsync = ref.watch(courseStatsProvider(courseId));
    final courseAttendanceAsync = ref.watch(courseAttendanceProvider(courseId));
    final adminController = ref.read(adminControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du cours'),
        actions: [
          IconButton(
            onPressed: () {
              adminController.refreshCourseAttendance(courseId);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: courseStatsAsync.when(
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(courseStatsProvider(courseId));
              ref.invalidate(courseAttendanceProvider(courseId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête du cours
                  GradientHeaderCard(
                    title: stats.courseName,
                    subtitle: stats.instructorName,
                    icon: Icons.school,
                    gradient: AppTheme.primaryGradient,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Horaires
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${DateFormat('HH:mm').format(stats.startTime)} - ${DateFormat('HH:mm').format(stats.endTime)}',
                                style: AppTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Date complète
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                                    .format(stats.startTime),
                                style: AppTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistiques de présence
                  Text(
                    'Statistiques',
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.borderRadiusLarge,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stats.presentStudents}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Présents',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.borderRadiusLarge,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stats.lateStudents}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'En retard',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.borderRadiusLarge,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stats.absentStudents}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Absents',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: stats.attendanceRate >= 80
                              ? AppTheme.successGradient
                              : stats.attendanceRate >= 60
                                  ? AppTheme.warningGradient
                                  : AppTheme.errorGradient,
                          borderRadius: AppTheme.borderRadiusLarge,
                          boxShadow: AppTheme.elevatedShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stats.attendanceRate.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Taux de présence',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Liste des étudiants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Liste de présence',
                        style: AppTheme.headingSmall,
                      ),
                      Text(
                        '${stats.totalStudents} étudiants',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  courseAttendanceAsync.when(
                    data: (attendanceList) {
                      if (attendanceList.isEmpty) {
                        return const EmptyState(
                          icon: Icons.people_outline,
                          title: 'Aucun étudiant',
                          subtitle: 'Aucun étudiant inscrit à ce cours',
                        );
                      }

                      // Trier par statut puis par nom
                      final sortedList = List<StudentAttendance>.from(attendanceList);
                      sortedList.sort((a, b) {
                        // Ordre: Present -> Late -> Absent
                        final statusOrder = {
                          AttendanceStatus.present: 0,
                          AttendanceStatus.late: 1,
                          AttendanceStatus.absent: 2,
                        };
                        final statusCompare = statusOrder[a.status]!
                            .compareTo(statusOrder[b.status]!);
                        if (statusCompare != 0) return statusCompare;
                        return a.studentName.compareTo(b.studentName);
                      });

                      return Column(
                        children: sortedList.map((attendance) {
                          return EditableStudentAttendanceTile(
                            attendance: attendance,
                            onMarkPresent: () {
                              // TODO: Implémenter avec table attendance ou système de pointing
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fonctionnalité non disponible sans table attendance'),
                                ),
                              );
                            },
                            onMarkAbsent: () {
                              // TODO: Implémenter avec table attendance ou système de pointing
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fonctionnalité non disponible sans table attendance'),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: AppTheme.borderRadiusLarge,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: AppTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
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
    );
  }
}
