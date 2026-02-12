import 'package:a4_iot/domain/entities/courses.dart';
import 'package:a4_iot/domain/repositories/courses.dart';
import 'package:a4_iot/data/datasources/local/courses.dart';
import 'package:a4_iot/data/datasources/remote/courses.dart';
import 'package:a4_iot/data/models/courses.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDatasource remote;
  final CourseLocalDatasource local;

  CourseRepositoryImpl(this.remote, this.local);

  @override
  Future<List<Courses>> getCourses() async {
    try {
      final remoteData = await remote.fetchCourses();
      await local.cacheCourses(remoteData);

      return remoteData.map((e) => CoursesModel.fromMap(e)).toList();
    } catch (_) {
      final localData = await local.getCachedCourses();
      return localData.map((e) => CoursesModel.fromMap(e)).toList();
    }
  }

  @override
  Future<Courses> getCourseById(String id) async {
    final remoteData = await remote.fetchCourseById(id);
    return CoursesModel.fromMap(remoteData);
  }

  @override
  Future<List<Courses>> getCoursesByIds(List<String> ids) async {
    final remoteData = await remote.fetchCoursesByIds(ids);
    return remoteData.map((e) => CoursesModel.fromMap(e)).toList();
  }

  @override
  Future<List<Courses>> getCoursesByReservationIds(List<String> ids) async {
    final remoteData = await remote.fetchCoursesByReservationIds(ids);
    return remoteData.map((e) => CoursesModel.fromMap(e)).toList();
  }

  @override
  Future<List<HomeCourses>> getHomeCoursesById(String id) async {
    try {
      final remoteData = await remote
          .fetchHomeCourseByUserId(id)
          .timeout(const Duration(seconds: 5));

      final List<HomeCourses> result = [];

      for (final row in remoteData) {
        result.add(HomeCoursesModel.fromMap(row));
      }

      await local.cacheUserCourses(
        result.map((e) => (e as HomeCoursesModel).toMap()).toList(),
      );

      return result;
    } catch (e) {
      print('Error fetching home courses: $e');
      
      final localData = await local.getCachedUserCourses();

      return localData != null
          ? localData.map((e) => HomeCoursesModel.fromCache(e)).toList()
          : throw Exception('No cached courses found');
    }
  }

  Future<List<Courses>> getCoursesByUsersId(String id) async {
    try {
      final remoteData = await remote.fetchUsersCourses(id);
      await local.cacheCourses(remoteData);

      return remoteData.map((e) => CoursesModel.fromMap(e)).toList();
    } catch (_) {
      final localData = await local.getCachedCourses();
      return localData.map((e) => CoursesModel.fromMap(e)).toList();
    }
  }

  @override
  Future<void> setCourses(
    String courseName,
    String instructor,
    String room,
    String reservation,
  ) async {
    await remote.createCourse(courseName, instructor, room, reservation);
  }

  @override
  Future<void> updateCourse(
    String id,
    String? courseName,
    String? instructor,
    String? room,
    String? reservation,
  ) async {
    {
      await remote.updateCourse(id, courseName, instructor, room, reservation);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    await remote.deleteCourse(id);
  }
}
