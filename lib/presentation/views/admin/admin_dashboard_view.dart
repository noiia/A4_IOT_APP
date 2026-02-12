import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/presentation/controllers/admin.dart';
import 'package:a4_iot/presentation/controllers/users.dart';
import 'package:a4_iot/presentation/widget/admin/stat_card.dart';
import 'package:a4_iot/presentation/widget/admin/course_card.dart';
import 'package:a4_iot/presentation/widget/admin/notification_badge.dart';
import 'package:a4_iot/presentation/views/admin/course_detail_view.dart';
import 'package:a4_iot/presentation/views/admin/late_students_view.dart';
import 'package:a4_iot/presentation/views/admin/absent_students_view.dart';

/// Vue du tableau de bord administrateur
class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeUsersAsync = ref.watch(homeUsersProvider);
    final campusIdAsync = ref.watch(userCampusIdProvider);

    return homeUsersAsync.when(
      data: (user) {
        final instructorId = user.id;

        return campusIdAsync.when(
          data: (campusId) {
            final dashboardStatsAsync = ref.watch(dashboardStatsProvider(campusId));
            final todayCoursesAsync = ref.watch(todayCoursesProvider(instructorId));
            final unreadCount = ref.watch(unreadNotificationsCountProvider);

            return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Admin'),
            actions: [
              NotificationBadge(
                count: unreadCount,
                onTap: () {
                  // TODO: Ouvrir le panneau de notifications
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider(campusId));
              ref.invalidate(todayCoursesProvider(instructorId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec salutation
                  Text(
                    'Bonjour, ${user.firstName} !',
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Voici un aperçu de la journée',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Statistiques
                  dashboardStatsAsync.when(
                    data: (stats) {
                      return Column(
                        children: [
                          // Stat principale
                          StatCard(
                            title: 'Taux de présence',
                            value: '${stats.attendanceRate.toStringAsFixed(1)}%',
                            subtitle: 'aujourd\'hui',
                            icon: Icons.trending_up,
                            color: stats.attendanceRate >= 80
                                ? AppTheme.successColor
                                : stats.attendanceRate >= 60
                                    ? AppTheme.warningColor
                                    : AppTheme.errorColor,
                            gradient: stats.attendanceRate >= 80
                                ? AppTheme.successGradient
                                : stats.attendanceRate >= 60
                                    ? AppTheme.warningGradient
                                    : AppTheme.errorGradient,
                          ),
                          const SizedBox(height: 16),

                          // Grille de stats
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.2,
                            children: [
                              CompactStatCard(
                                title: 'Présents',
                                value: '${stats.presentToday}',
                                icon: Icons.check_circle,
                                color: AppTheme.successColor,
                              ),
                              CompactStatCard(
                                title: 'En retard',
                                value: '${stats.lateToday}',
                                icon: Icons.schedule,
                                color: AppTheme.warningColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LateStudentsView(
                                        campusId: campusId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              CompactStatCard(
                                title: 'Absents',
                                value: '${stats.absentToday}',
                                icon: Icons.cancel,
                                color: AppTheme.errorColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AbsentStudentsView(
                                        campusId: campusId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              CompactStatCard(
                                title: 'Total étudiants',
                                value: '${stats.totalStudents}',
                                icon: Icons.people,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ],
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

                  const SizedBox(height: 32),

                  // Cours du jour
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mes cours aujourd\'hui',
                        style: AppTheme.headingSmall,
                      ),
                      todayCoursesAsync.whenData((courses) {
                        return SimpleBadge(
                          label: '${courses.length}',
                          color: AppTheme.primaryColor,
                          icon: Icons.event,
                          isSmall: true,
                        );
                      }).value ?? const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  todayCoursesAsync.when(
                    data: (courses) {
                      if (courses.isEmpty) {
                        return EmptyState(
                          icon: Icons.event_busy,
                          title: 'Aucun cours aujourd\'hui',
                          subtitle:
                              'Profitez de votre journée sans cours !',
                        );
                      }

                      return Column(
                        children: courses.map((course) {
                          return CourseCard(
                            course: course,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CourseDetailView(
                                    courseId: course.courseId,
                                  ),
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
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Impossible de charger les cours',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.errorColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions rapides
                  Text(
                    'Actions rapides',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _QuickActionCard(
                        title: 'Retards',
                        icon: Icons.schedule,
                        color: AppTheme.warningColor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LateStudentsView(
                                campusId: campusId,
                              ),
                            ),
                          );
                        },
                      ),
                      _QuickActionCard(
                        title: 'Absences',
                        icon: Icons.cancel,
                        color: AppTheme.errorColor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AbsentStudentsView(
                                campusId: campusId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Text('Erreur lors du chargement du campus: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}

/// Carte d'action rapide
class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadiusLarge,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppTheme.borderRadiusLarge,
          boxShadow: AppTheme.coloredShadow(color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
