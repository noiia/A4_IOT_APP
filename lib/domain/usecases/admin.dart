import 'package:a4_iot/domain/entities/admin_stats.dart';
import 'package:a4_iot/domain/repositories/admin_repository.dart';

/// Use cases pour les fonctionnalités administrateur

/// Récupère les statistiques du tableau de bord
class GetDashboardStats {
  final AdminRepository repository;

  GetDashboardStats(this.repository);

  Future<AdminDashboardStats> call(String campusId) async {
    return await repository.getDashboardStats(campusId);
  }
}

/// Récupère les cours du jour pour un enseignant
class GetTodayCoursesForInstructor {
  final AdminRepository repository;

  GetTodayCoursesForInstructor(this.repository);

  Future<List<AdminCourse>> call(String instructorId) async {
    return await repository.getTodayCoursesForInstructor(instructorId);
  }
}

/// Récupère les statistiques de présence pour un cours
class GetCourseAttendanceStats {
  final AdminRepository repository;

  GetCourseAttendanceStats(this.repository);

  Future<CourseAttendanceStats> call(String courseId) async {
    return await repository.getCourseAttendanceStats(courseId);
  }
}

/// Récupère la liste des étudiants en retard aujourd'hui
class GetLateStudentsToday {
  final AdminRepository repository;

  GetLateStudentsToday(this.repository);

  Future<List<StudentAttendance>> call(String campusId) async {
    return await repository.getLateStudentsToday(campusId);
  }
}

/// Récupère la liste des étudiants absents aujourd'hui
class GetAbsentStudentsToday {
  final AdminRepository repository;

  GetAbsentStudentsToday(this.repository);

  Future<List<StudentAttendance>> call(String campusId) async {
    return await repository.getAbsentStudentsToday(campusId);
  }
}

/// Récupère l'historique de présence d'un étudiant
class GetStudentAttendanceHistory {
  final AdminRepository repository;

  GetStudentAttendanceHistory(this.repository);

  Future<List<StudentAttendance>> call(String studentId) async {
    return await repository.getStudentAttendanceHistory(studentId);
  }
}

/// Récupère les présences pour un cours spécifique
class GetCourseAttendance {
  final AdminRepository repository;

  GetCourseAttendance(this.repository);

  Future<List<StudentAttendance>> call(String courseId) async {
    return await repository.getCourseAttendance(courseId);
  }
}
