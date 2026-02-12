import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Repository abstrait pour les fonctionnalités administrateur
abstract class AdminRepository {
  /// Récupère les statistiques du tableau de bord
  Future<AdminDashboardStats> getDashboardStats(String campusId);

  /// Récupère les cours du jour pour un enseignant
  Future<List<AdminCourse>> getTodayCoursesForInstructor(String instructorId);

  /// Récupère les statistiques de présence pour un cours
  Future<CourseAttendanceStats> getCourseAttendanceStats(String courseId);

  /// Récupère la liste des étudiants en retard aujourd'hui
  Future<List<StudentAttendance>> getLateStudentsToday(String campusId);

  /// Récupère la liste des étudiants absents aujourd'hui
  Future<List<StudentAttendance>> getAbsentStudentsToday(String campusId);

  /// Récupère l'historique de présence d'un étudiant
  Future<List<StudentAttendance>> getStudentAttendanceHistory(String studentId);

  /// Récupère les présences pour un cours spécifique
  Future<List<StudentAttendance>> getCourseAttendance(String courseId);
}
