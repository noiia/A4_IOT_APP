import 'package:a4_iot/data/datasources/remote/admin.dart';
import 'package:a4_iot/domain/entities/admin_stats.dart';
import 'package:a4_iot/domain/repositories/admin_repository.dart';

/// Implémentation du repository administrateur
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AdminDashboardStats> getDashboardStats(String campusId) async {
    return await remoteDataSource.fetchDashboardStats(campusId);
  }

  @override
  Future<List<AdminCourse>> getTodayCoursesForInstructor(
    String instructorId,
  ) async {
    return await remoteDataSource.fetchTodayCoursesForInstructor(instructorId);
  }

  @override
  Future<CourseAttendanceStats> getCourseAttendanceStats(
    String courseId,
  ) async {
    return await remoteDataSource.fetchCourseAttendanceStats(courseId);
  }

  @override
  Future<List<StudentAttendance>> getLateStudentsToday(String campusId) async {
    return await remoteDataSource.fetchLateStudentsToday(campusId);
  }

  @override
  Future<List<StudentAttendance>> getAbsentStudentsToday(
    String campusId,
  ) async {
    return await remoteDataSource.fetchAbsentStudentsToday(campusId);
  }

  @override
  Future<List<StudentAttendance>> getStudentAttendanceHistory(
    String studentId,
  ) async {
    return await remoteDataSource.fetchStudentAttendanceHistory(studentId);
  }

  @override
  Future<List<StudentAttendance>> getCourseAttendance(String courseId) async {
    return await remoteDataSource.fetchCourseAttendance(courseId);
  }
}
