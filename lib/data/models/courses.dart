import 'package:a4_iot/domain/entities/courses.dart';

class CoursesModel extends Courses {
  CoursesModel({
    required super.id,
    required super.courseName,
    required super.instructorId,
    required super.roomId,
    required super.reservationId,
    required super.createdAt,
  });

  factory CoursesModel.fromMap(Map<String, dynamic> map) {
    return CoursesModel(
      id: map['id'],
      courseName: map['course_name'],
      instructorId: map['instructor_id'],
      roomId: map['room_id'],
      reservationId: map['reservation_id'],
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "course_name": courseName,
    "instructor_id": instructorId,
    "room_id": roomId,
    "reservation_id": reservationId,
    "created_at": createdAt.toIso8601String(),
  };
}

class HomeCoursesModel extends HomeCourses {
  HomeCoursesModel({
    required super.id,
    required super.courseName,
    required super.instructor,
    required super.room,
    required super.reservationStart,
    required super.reservationEnd,
  });

  factory HomeCoursesModel.fromMap(Map<String, dynamic> coursesMap) {
    return HomeCoursesModel(
      id: coursesMap['reservation_id'] ?? coursesMap['id'] ?? '',
      courseName: coursesMap['course_name'] ?? 'Inconnu',
      instructor:
          (coursesMap['instructor_first_name'] != null &&
              coursesMap['instructor_last_name'] != null)
          ? "${coursesMap['instructor_first_name']} ${coursesMap['instructor_last_name']}"
          : (coursesMap['instructor'] ?? 'Inconnu'),
      room: coursesMap['room_name'] ?? coursesMap['rooms'] ?? 'Inconnu',
      reservationStart: DateTime.parse(coursesMap['start'] as String),
      reservationEnd: DateTime.parse(coursesMap['ends'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "course_name": courseName,
    "instructor": instructor,
    "rooms": room,
    "reservation_start": reservationStart.toIso8601String(),
    "reservation_end": reservationEnd.toIso8601String(),
  };

  factory HomeCoursesModel.fromCache(Map<String, dynamic> coursesMap) {
    return HomeCoursesModel(
      id: coursesMap['id'] ?? '',
      courseName: coursesMap['course_name'] ?? 'Inconnu',
      instructor: coursesMap['instructor'] ?? 'Inconnu',
      room: coursesMap['rooms'] ?? 'Inconnu',
      reservationStart: DateTime.parse(
        coursesMap['reservation_start'] as String,
      ),
      reservationEnd: DateTime.parse(coursesMap['reservation_end'] as String),
    );
  }
}
