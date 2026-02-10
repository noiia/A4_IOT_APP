import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:a4_iot/domain/usecases/courses.dart';
import 'package:a4_iot/domain/entities/courses.dart';
import 'package:a4_iot/data/datasources/local/courses.dart';
import 'package:a4_iot/data/datasources/remote/courses.dart';
import 'package:a4_iot/data/repositories/courses_impl.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final courseRemoteProvider = Provider<CourseRemoteDatasource>((ref) {
  return CourseRemoteDatasource(ref.read(supabaseProvider));
});

final courseLocalProvider = Provider<CourseLocalDatasource>((ref) {
  return CourseLocalDatasource();
});

final courseRepositoryProvider = Provider<CourseRepositoryImpl>((ref) {
  return CourseRepositoryImpl(
    ref.read(courseRemoteProvider),
    ref.read(courseLocalProvider),
  );
});

final getCoursesProvider = Provider<GetCourses>((ref) {
  return GetCourses(ref.read(courseRepositoryProvider));
});

final getCourseByIdProvider = Provider<GetCoursesById>((ref) {
  return GetCoursesById(ref.read(courseRepositoryProvider));
});

final getCoursesByIdsProvider = Provider<GetCoursesByIds>((ref) {
  return GetCoursesByIds(ref.read(courseRepositoryProvider));
});

final getCoursesByReservationIdsProvider = Provider<GetCoursesByReservationIds>(
  (ref) {
    return GetCoursesByReservationIds(ref.read(courseRepositoryProvider));
  },
);

final getHomeCoursesByIdProvider = Provider<GetHomeCoursesByIds>((ref) {
  return GetHomeCoursesByIds(ref.read(courseRepositoryProvider));
});

final createCourseProvider = Provider<CreateCourses>((ref) {
  return CreateCourses(ref.read(courseRepositoryProvider));
});

final updateCourseProvider = Provider<UpdateCourses>((ref) {
  return UpdateCourses(ref.read(courseRepositoryProvider));
});

final deleteCourseProvider = Provider<DeleteCourses>((ref) {
  return DeleteCourses(ref.read(courseRepositoryProvider));
});

final coursesByIdsProvider = FutureProvider.family<List<Courses>, List<String>>(
  (ref, userId) async {
    final getCoursesByIds = ref.read(getCoursesByIdsProvider);

    return getCoursesByIds(userId);
  },
);

final coursesByReservationIdsProvider =
    FutureProvider.family<List<Courses>, String>((ref, userId) async {
      final getCoursesByReservationIds = ref.read(
        getCoursesByReservationIdsProvider,
      );
      final ids = userId.split(',');
      return getCoursesByReservationIds(ids);
    });

final homeCoursesIdsProvider = FutureProvider.autoDispose
    .family<List<HomeCourses>, String>((ref, userBadgeId) async {
      final getHomeCoursesByIds = ref.read(getHomeCoursesByIdProvider);
      return await getHomeCoursesByIds(userBadgeId);
    });
