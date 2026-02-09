import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:a4_iot/domain/entities/courses.dart';
import 'package:a4_iot/domain/entities/users.dart';
import 'package:a4_iot/presentation/controllers/courses.dart';
import 'package:a4_iot/presentation/controllers/users.dart';
import 'package:a4_iot/presentation/widget/course_list.dart';
import 'package:a4_iot/presentation/widget/profile_card.dart';
import 'package:a4_iot/utils/ble_listening.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  Widget _buildPage(
    HomeUsers currentUser,
    List<HomeCourses> courses,
    String bleStatusJson,
    String bleNextClassJson,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 500,
                    child: ProfileCard(
                      firstName: currentUser.firstName,
                      lastName: currentUser.lastName,
                      status: currentUser.status,
                      lastPointing:
                          currentUser.lastPointing?.toIso8601String() ??
                          "Pas encore pointé",
                      proms: currentUser.promsName,
                      campus: currentUser.campusName,
                      avatarUrl: currentUser.avatarUrl,
                      bleStatusJson: bleStatusJson.isEmpty
                          ? null
                          : bleStatusJson,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 500,
                    child: courses.isEmpty && bleNextClassJson.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucun cours pour le moment",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : CourseList(
                            courses: courses,
                            bleNextClassJson: bleNextClassJson.isEmpty
                                ? null
                                : bleNextClassJson,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(homeUsersProvider);
    final bleStatusJson = ref.watch(statusDataProvider);
    final bleNextClassJson = ref.watch(nextClassDataProvider);

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur user : $e")),
        data: (currentUser) {
          final coursesDataAsync = ref.watch(
            homeCoursesIdsProvider(currentUser.badgeId),
          );
          return coursesDataAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
            error: (e, _) => Center(child: Text("Erreur cours : $e")),
            data: (coursesData) => _buildPage(
              currentUser,
              coursesData,
              bleStatusJson,
              bleNextClassJson,
            ),
          );
        },
      ),
    );
  }
}
