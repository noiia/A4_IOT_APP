import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a4_iot/data/datasources/remote/admin.dart';
import 'package:a4_iot/data/repositories/admin_impl.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';
import 'package:a4_iot/domain/repositories/admin_repository.dart';
import 'package:a4_iot/domain/usecases/admin.dart';
import 'package:a4_iot/presentation/controllers/users.dart';

// === PROVIDERS DE DATASOURCE ET REPOSITORY ===

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AdminRemoteDataSource(supabaseClient: supabase);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    remoteDataSource: ref.read(adminRemoteDataSourceProvider),
  );
});

// === PROVIDER POUR RÉCUPÉRER LE CAMPUS ID ===

/// Provider pour récupérer le campusId de l'utilisateur connecté
final userCampusIdProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final supabase = ref.read(supabaseProvider);
  
  // Récupérer l'utilisateur pour vérifier son statut
  final userResponse = await supabase
      .from('users')
      .select('proms_id, badge_id, status')
      .eq('auth_user_id', user.id)
      .single();

  final status = userResponse['status']?.toString().toLowerCase();
  
  // Si c'est un étudiant: récupérer via proms_id
  if (status == 'student') {
    final promsId = userResponse['proms_id'];
    if (promsId == null) {
      throw Exception('Student has no proms_id');
    }

    final promsResponse = await supabase
        .from('proms')
        .select('campus_id')
        .eq('id', promsId)
        .single();

    return promsResponse['campus_id']?.toString() ?? '';
  }
  
  // Si c'est un teacher/instructor: récupérer via un cours
  if (status == 'teacher' || status == 'instructor') {
    final badgeId = userResponse['badge_id'];
    print("🔍 DEBUG badgeid: $badgeId (type: ${badgeId.runtimeType})");
    
    try {
      // Récupérer TOUS les cours du teacher pour debug
      final allCoursesResponse = await supabase
          .from('courses')
          .select('id, proms_id, instructor_id')
          .eq('instructor_id', badgeId);
      print("🔍 DEBUG tous les cours avec cet instructor_id: $allCoursesResponse");
      
      // Récupérer un cours du teacher
      final courseResponse = await supabase
          .from('courses')
          .select('proms_id')
          .eq('instructor_id', badgeId)
          .limit(1)
          .maybeSingle();
      print("✅ DEBUG courseResponse: $courseResponse");

      if (courseResponse == null || courseResponse['proms_id'] == null) {
        print("❌ DEBUG: courseResponse est null ou proms_id manquant");
        throw Exception('Teacher has no courses assigned');
      }

      // Récupérer le campus_id depuis la promo
      final promsResponse = await supabase
          .from('proms')
          .select('campus_id')
          .eq('id', courseResponse['proms_id'])
          .single();
      
      print("✅ DEBUG campus_id: ${promsResponse['campus_id']}");
      return promsResponse['campus_id']?.toString() ?? '';
    } catch (e, stackTrace) {
      print("❌ ERREUR lors de la récupération du campus_id: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  throw Exception('Unknown user status: $status');
});

// === PROVIDERS DE USE CASES ===

final getDashboardStatsProvider = Provider<GetDashboardStats>((ref) {
  return GetDashboardStats(ref.read(adminRepositoryProvider));
});

final getTodayCoursesForInstructorProvider =
    Provider<GetTodayCoursesForInstructor>((ref) {
  return GetTodayCoursesForInstructor(ref.read(adminRepositoryProvider));
});

final getCourseAttendanceStatsProvider =
    Provider<GetCourseAttendanceStats>((ref) {
  return GetCourseAttendanceStats(ref.read(adminRepositoryProvider));
});

final getLateStudentsTodayProvider = Provider<GetLateStudentsToday>((ref) {
  return GetLateStudentsToday(ref.read(adminRepositoryProvider));
});

final getAbsentStudentsTodayProvider =
    Provider<GetAbsentStudentsToday>((ref) {
  return GetAbsentStudentsToday(ref.read(adminRepositoryProvider));
});

final getStudentAttendanceHistoryProvider =
    Provider<GetStudentAttendanceHistory>((ref) {
  return GetStudentAttendanceHistory(ref.read(adminRepositoryProvider));
});

final getCourseAttendanceProvider = Provider<GetCourseAttendance>((ref) {
  return GetCourseAttendance(ref.read(adminRepositoryProvider));
});

// === PROVIDERS DE DONNÉES ===

/// Provider pour les statistiques du tableau de bord
final dashboardStatsProvider = FutureProvider.family<AdminDashboardStats, String>(
  (ref, campusId) async {
    final getDashboardStats = ref.read(getDashboardStatsProvider);
    return await getDashboardStats(campusId);
  },
);

/// Provider pour les cours du jour d'un enseignant
final todayCoursesProvider = FutureProvider.family<List<AdminCourse>, String>(
  (ref, instructorId) async {
    final getTodayCourses = ref.read(getTodayCoursesForInstructorProvider);
    return await getTodayCourses(instructorId);
  },
);

/// Provider pour les statistiques d'un cours
final courseStatsProvider =
    FutureProvider.family<CourseAttendanceStats, String>(
  (ref, courseId) async {
    final getCourseStats = ref.read(getCourseAttendanceStatsProvider);
    return await getCourseStats(courseId);
  },
);

/// Provider pour les étudiants en retard aujourd'hui
final lateStudentsTodayProvider =
    FutureProvider.family<List<StudentAttendance>, String>(
  (ref, campusId) async {
    final getLateStudents = ref.read(getLateStudentsTodayProvider);
    return await getLateStudents(campusId);
  },
);

/// Provider pour les étudiants absents aujourd'hui
final absentStudentsTodayProvider =
    FutureProvider.family<List<StudentAttendance>, String>(
  (ref, campusId) async {
    final getAbsentStudents = ref.read(getAbsentStudentsTodayProvider);
    return await getAbsentStudents(campusId);
  },
);

/// Provider pour l'historique de présence d'un étudiant
final studentAttendanceHistoryProvider =
    FutureProvider.family<List<StudentAttendance>, String>(
  (ref, studentId) async {
    final getHistory = ref.read(getStudentAttendanceHistoryProvider);
    return await getHistory(studentId);
  },
);

/// Provider pour les présences d'un cours
final courseAttendanceProvider =
    FutureProvider.family<List<StudentAttendance>, String>(
  (ref, courseId) async {
    final getCourseAttendance = ref.read(getCourseAttendanceProvider);
    return await getCourseAttendance(courseId);
  },
);

// === CONTROLLER ADMIN ===

/// Controller pour gérer les actions administrateur
class AdminController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Rafraîchir les statistiques du dashboard
  Future<void> refreshDashboardStats(String campusId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.invalidate(dashboardStatsProvider(campusId));
    });
  }

  /// Rafraîchir les cours du jour
  Future<void> refreshTodayCourses(String instructorId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.invalidate(todayCoursesProvider(instructorId));
    });
  }

  /// Rafraîchir les présences d'un cours
  Future<void> refreshCourseAttendance(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.invalidate(courseAttendanceProvider(courseId));
      ref.invalidate(courseStatsProvider(courseId));
    });
  }

  // NOTE: Les méthodes markStudentPresent et markStudentAbsent ne sont pas
  // implémentées car elles nécessitent une table 'attendance' qui n'existe pas
  // dans le schéma actuel. Les présences sont gérées via la table 'pointing'.
}

final adminControllerProvider =
    AsyncNotifierProvider<AdminController, void>(() {
  return AdminController();
});

// === NOTIFICATIONS ===

/// Notifier pour les notifications admin
class AdminNotificationsNotifier extends Notifier<List<AdminNotification>> {
  @override
  List<AdminNotification> build() {
    return [];
  }

  /// Ajouter une notification
  void addNotification(AdminNotification notification) {
    state = [notification, ...state];
  }

  /// Marquer une notification comme lue
  void markAsRead(String notificationId) {
    state = state.map((n) {
      if (n.id == notificationId) {
        return AdminNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          metadata: n.metadata,
        );
      }
      return n;
    }).toList();
  }

  /// Marquer toutes les notifications comme lues
  void markAllAsRead() {
    state = state.map((n) {
      return AdminNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        createdAt: n.createdAt,
        isRead: true,
        metadata: n.metadata,
      );
    }).toList();
  }

  /// Supprimer une notification
  void removeNotification(String notificationId) {
    state = state.where((n) => n.id != notificationId).toList();
  }

  /// Supprimer toutes les notifications
  void clearAll() {
    state = [];
  }

  /// Nombre de notifications non lues
  int get unreadCount => state.where((n) => !n.isRead).length;
}

final adminNotificationsProvider =
    NotifierProvider<AdminNotificationsNotifier, List<AdminNotification>>(() {
  return AdminNotificationsNotifier();
});

/// Provider pour le nombre de notifications non lues
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(adminNotificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});
