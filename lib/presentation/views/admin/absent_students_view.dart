import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/presentation/controllers/admin.dart';
import 'package:a4_iot/presentation/widget/admin/student_attendance_tile.dart';
import 'package:a4_iot/presentation/widget/admin/notification_badge.dart';
import 'package:a4_iot/presentation/views/admin/student_history_view.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Vue affichant les étudiants absents aujourd'hui
class AbsentStudentsView extends ConsumerWidget {
  final String campusId;

  const AbsentStudentsView({
    super.key,
    required this.campusId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final absentStudentsAsync = ref.watch(absentStudentsTodayProvider(campusId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Étudiants absents'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(absentStudentsTodayProvider(campusId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(absentStudentsTodayProvider(campusId));
        },
        child: absentStudentsAsync.when(
          data: (absentStudents) {
            if (absentStudents.isEmpty) {
              return const EmptyState(
                icon: Icons.celebration,
                title: 'Aucune absence !',
                subtitle:
                    'Tous les étudiants sont présents aujourd\'hui.',
              );
            }

            // Grouper par cours
            final groupedByCourse = <String, List<StudentAttendance>>{};
            for (var student in absentStudents) {
              final courseName = student.courseName ?? 'Cours inconnu';
              groupedByCourse.putIfAbsent(courseName, () => []);
              groupedByCourse[courseName]!.add(student);
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Résumé
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.errorGradient,
                    borderRadius: AppTheme.borderRadiusLarge,
                    boxShadow: AppTheme.coloredShadow(AppTheme.errorColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: AppTheme.borderRadiusMedium,
                        ),
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total des absences',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${absentStudents.length} étudiant${absentStudents.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Liste groupée par cours
                ...groupedByCourse.entries.map((entry) {
                  final courseName = entry.key;
                  final students = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                courseName,
                                style: AppTheme.titleMedium,
                              ),
                            ),
                            SimpleBadge(
                              label: students.length.toString(),
                              color: AppTheme.errorColor,
                              isSmall: true,
                            ),
                          ],
                        ),
                      ),
                      ...students.map((student) {
                        return StudentAttendanceTile(
                          attendance: student,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StudentHistoryView(
                                  studentId: student.studentId,
                                  studentName: student.studentName,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
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
