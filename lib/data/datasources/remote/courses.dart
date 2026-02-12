import 'package:supabase_flutter/supabase_flutter.dart';

class CourseRemoteDatasource {
  final SupabaseClient client;

  CourseRemoteDatasource(this.client);

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    return await client.from('courses').select();
  }

  Future<Map<String, dynamic>> fetchCourseById(String id) async {
    return await client.from('courses').select().eq('id', id).single();
  }

  Future<List<Map<String, dynamic>>> fetchCoursesByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    return await client.from('courses').select().filter('id', 'in', ids);
  }

  Future<List<Map<String, dynamic>>> fetchCoursesByReservationIds(
    List<String> ids,
  ) async {
    return await client
        .from('courses')
        .select()
        .filter('reservation_id', 'in', ids);
  }

  Future<List<Map<String, dynamic>>> fetchCoursesByInstructor(String id) async {
    final res = await client.rpc(
      'get_today_courses_by_instructor',
      params: {'p_instructor_id': id},
    );

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchCoursesForStudent(String id) async {
    final res = await client
        .from('courses')
        .select('''
        *,
        reservation:reservations (
          *,
          users
        ),
        room:rooms (*)
      ''')
        .contains('reservation.users', [id]);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchUsersCourses(String id) async {
    final instructorCourses = await fetchCoursesByInstructor(id);

    if (instructorCourses.isNotEmpty) {
      return instructorCourses;
    }

    return await fetchCoursesForStudent(id);
  }

  Future<List<Map<String, dynamic>>> fetchHomeCourseByUserId(String id) async {
    final res = await Supabase.instance.client.rpc(
      'get_today_reservations_by_user',
      params: {'p_user_id': id},
    );

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> createCourse(
    String courseName,
    String instructor,
    String room,
    String reservation,
  ) async {
    return await client.from('courses').insert({
      'course_name': courseName,
      'instructor': instructor,
      'room': room,
      'reservation': reservation,
    });
  }

  Future<void> updateCourse(
    String id,
    String? courseName,
    String? instructor,
    String? room,
    String? reservation,
  ) async {
    return await client
        .from('courses')
        .update({
          'course_name': courseName,
          'instructor': instructor,
          'room': room,
          'reservation': reservation,
        })
        .eq('id', id);
  }

  Future<void> deleteCourse(String id) async {
    return await client.from('courses').delete().eq('id', id);
  }
}
