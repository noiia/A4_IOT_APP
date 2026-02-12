import 'package:a4_iot/data/models/admin_stats.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource distant pour les fonctionnalités administrateur
/// Simplifié pour correspondre au nouveau schéma (courses, proms, pointing, slots)
class AdminRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdminRemoteDataSource({required this.supabaseClient});

  /// Récupère les statistiques du tableau de bord (simplifiées)
  Future<AdminDashboardStatsModel> fetchDashboardStats(String campusId) async {
    try {
      // Récupérer toutes les proms du campus
      final promsResponse = await supabaseClient
          .from('proms')
          .select('id')
          .eq('campus_id', campusId);

      final promsIds = (promsResponse as List)
          .map((p) => p['id'].toString())
          .toList();

      // Total étudiants du campus (students dans proms de ce campus)
      int totalStudents = 0;
      if (promsIds.isNotEmpty) {
        final studentsResponse = await supabaseClient
            .from('users')
            .select('auth_user_id')
            .inFilter('proms_id', promsIds)
            .eq('status', 'student');
        
        totalStudents = studentsResponse.length;
      }

      // Pointages aujourd'hui
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final pointingsResponse = await supabaseClient
          .from('pointing')
          .select('user_badge_id')
          .gte('Date', startOfDay.toIso8601String())
          .lte('Date', endOfDay.toIso8601String());

      final presentToday = pointingsResponse.length;

      // Calculs simplifiés (pas de système absent/late sans table attendance)
      final attendanceRate = totalStudents > 0
          ? (presentToday / totalStudents * 100)
          : 0.0;

      return AdminDashboardStatsModel(
        totalStudents: totalStudents,
        presentToday: presentToday,
        absentToday: 0, // Non calculable sans table attendance
        lateToday: 0,   // Non calculable sans table attendance
        attendanceRate: attendanceRate,
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  /// Récupère les cours du jour pour un enseignant
  Future<List<AdminCourseModel>> fetchTodayCoursesForInstructor(
    String instructorId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Récupérer l'enseignant pour avoir son badge_id
      final instructorResponse = await supabaseClient
          .from('users')
          .select('badge_id, first_name, last_name')
          .eq('auth_user_id', instructorId)
          .single();

      final badgeId = instructorResponse['badge_id'];
      final instructorName = '${instructorResponse['first_name']} ${instructorResponse['last_name']}';

      // Récupérer les cours (instructor_id est un UUID qui pointe vers badge_id)
      final coursesResponse = await supabaseClient
          .from('courses')
          .select('*')
          .eq('instructor_id', badgeId)
          .gte('start', startOfDay.toIso8601String())
          .lte('start', endOfDay.toIso8601String())
          .order('start', ascending: true);

      final courses = <AdminCourseModel>[];

      for (var courseData in coursesResponse) {
        // Récupérer la promo
        String promoName = 'Promo inconnue';
        String? promoId;
        if (courseData['proms_id'] != null) {
          promoId = courseData['proms_id'].toString();
          final promoResponse = await supabaseClient
              .from('proms')
              .select('name')
              .eq('id', promoId)
              .maybeSingle();

          if (promoResponse != null) {
            promoName = promoResponse['name']?.toString() ?? 'Promo inconnue';
          }
        }

        // Compter les étudiants de la promo
        int totalStudents = 0;
        if (promoId != null) {
          final studentsResponse = await supabaseClient
              .from('users')
              .select('auth_user_id')
              .eq('proms_id', promoId)
              .eq('status', 'student');

          totalStudents = studentsResponse.length;
        }

        // Statistiques simplifiées (pas de présences sans table attendance)
        courses.add(AdminCourseModel(
          courseId: courseData['id'].toString(),
          courseName: courseData['course_name']?.toString() ?? 'Sans nom',
          instructorName: instructorName,
          instructorId: badgeId.toString(),
          startTime: DateTime.parse(courseData['start'].toString()),
          endTime: DateTime.parse(courseData['end'].toString()),
          roomName: courseData['room']?.toString() ?? 'Salle inconnue',
          roomId: null,
          promoName: promoName,
          promoId: promoId,
          totalStudents: totalStudents,
          presentStudents: 0, // Non calculable sans table attendance
          attendanceRate: 0.0,
        ));
      }

      return courses;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cours: $e');
    }
  }

  /// Récupère les statistiques de présence pour un cours (simplifiées)
  Future<CourseAttendanceStatsModel> fetchCourseAttendanceStats(
    String courseId,
  ) async {
    try {
      // Récupérer le cours
      final courseResponse = await supabaseClient
          .from('courses')
          .select('*')
          .eq('id', courseId)
          .single();

      // Récupérer l'enseignant
      final instructorResponse = await supabaseClient
          .from('users')
          .select('first_name, last_name')
          .eq('badge_id', courseResponse['instructor_id'])
          .single();

      final instructorName =
          '${instructorResponse['first_name']} ${instructorResponse['last_name']}';

      // Compter les étudiants de la promo
      int totalStudents = 0;
      if (courseResponse['proms_id'] != null) {
        final studentsResponse = await supabaseClient
            .from('users')
            .select('auth_user_id')
            .eq('proms_id', courseResponse['proms_id'])
            .eq('status', 'student');

        totalStudents = studentsResponse.length;
      }

      return CourseAttendanceStatsModel(
        courseId: courseId,
        courseName: courseResponse['course_name']?.toString() ?? 'Sans nom',
        instructorName: instructorName,
        startTime: DateTime.parse(courseResponse['start'].toString()),
        endTime: DateTime.parse(courseResponse['end'].toString()),
        totalStudents: totalStudents,
        presentStudents: 0,    // Non calculable sans table attendance
        absentStudents: 0,     // Non calculable sans table attendance
        lateStudents: 0,       // Non calculable sans table attendance
        attendanceRate: 0.0,
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des statistiques: $e');
    }
  }

  /// Retourne une liste vide (pas de table attendance)
  Future<List<StudentAttendanceModel>> fetchLateStudentsToday(
    String campusId,
  ) async {
    return [];
  }

  /// Retourne une liste vide (pas de table attendance)
  Future<List<StudentAttendanceModel>> fetchAbsentStudentsToday(
    String campusId,
  ) async {
    return [];
  }

  /// Retourne une liste vide (pas de table attendance)
  Future<List<StudentAttendanceModel>> fetchStudentAttendanceHistory(
    String studentId,
  ) async {
    return [];
  }

  /// Récupère les étudiants d'un cours (sans données de présence)
  Future<List<StudentAttendanceModel>> fetchCourseAttendance(
    String courseId,
  ) async {
    try {
      // Récupérer le cours
      final courseResponse = await supabaseClient
          .from('courses')
          .select('course_name, proms_id')
          .eq('id', courseId)
          .single();

      final courseName = courseResponse['course_name']?.toString() ?? 'Sans nom';

      // Récupérer tous les étudiants de la promo
      final studentsResponse = await supabaseClient
          .from('users')
          .select('auth_user_id, badge_id, first_name, last_name, proms_id')
          .eq('proms_id', courseResponse['proms_id'])
          .eq('status', 'student');

      // Récupérer la promo name une seule fois
      String? promoName;
      if (courseResponse['proms_id'] != null) {
        final promoResponse = await supabaseClient
            .from('proms')
            .select('name')
            .eq('id', courseResponse['proms_id'])
            .maybeSingle();
        promoName = promoResponse?['name']?.toString();
      }

      final attendanceList = <StudentAttendanceModel>[];

      for (var student in studentsResponse) {
        attendanceList.add(StudentAttendanceModel(
          studentId: student['auth_user_id'].toString(),
          studentName: '${student['first_name']} ${student['last_name']}',
          studentEmail: '', // Pas de colonne email dans le schéma
          studentPromo: promoName,
          status: AttendanceStatus.absent, // Par défaut absent sans table attendance
          courseId: courseId,
          courseName: courseName,
        ));
      }

      return attendanceList;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des étudiants du cours: $e');
    }
  }
}
