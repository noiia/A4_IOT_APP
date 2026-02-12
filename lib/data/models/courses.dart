import 'package:a4_iot/domain/entities/courses.dart';

class CoursesModel extends Courses {
  CoursesModel({
    required super.id,
    required super.courseName,
    required super.instructorId,
    required super.roomId,
    required super.createdAt,
    required super.start,
    required super.end,
    required super.room,
    required super.promsId,
  });

  factory CoursesModel.fromMap(Map<String, dynamic> map) {
    return CoursesModel(
      id: map['id']?.toString() ?? '',
      courseName: map['course_name']?.toString() ?? 'Cours sans nom',
      instructorId: map['instructor_id']?.toString() ?? '',
      roomId: map['room_id']?.toString() ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
      start: map['start'] != null 
          ? DateTime.parse(map['start'].toString()) 
          : DateTime.now(),
      end: map['end'] != null 
          ? DateTime.parse(map['end'].toString()) 
          : DateTime.now().add(Duration(hours: 1)),
      room: map['room']?.toString() ?? 'Salle inconnue',
      promsId: map['proms_id']?.toString() ?? ''
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "course_name": courseName,
    "instructor_id": instructorId,
    "room_id": roomId,
    "created_at": createdAt.toIso8601String(),
    "start": start.toIso8601String(),
    "end": end.toIso8601String(),
    "room": room,
    "proms_id": promsId,
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
      id: coursesMap['reservation_id']?.toString() ?? coursesMap['id']?.toString() ?? '',
      courseName: coursesMap['course_name']?.toString() ?? 'Inconnu',
      instructor:
          (coursesMap['instructor_first_name'] != null &&
              coursesMap['instructor_last_name'] != null)
          ? "${coursesMap['instructor_first_name']} ${coursesMap['instructor_last_name']}"
          : (coursesMap['instructor']?.toString() ?? 'Inconnu'),
      room: coursesMap['room_name']?.toString() ?? coursesMap['rooms']?.toString() ?? 'Inconnu',
      reservationStart: coursesMap['start'] != null 
          ? DateTime.parse(coursesMap['start'].toString()) 
          : DateTime.now(),
      reservationEnd: coursesMap['end'] != null 
          ? DateTime.parse(coursesMap['end'].toString()) 
          : DateTime.now().add(Duration(hours: 1)),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "course_name": courseName,
    "instructor": instructor,
    "rooms": room,
    "start": reservationStart.toIso8601String(),
    "end": reservationEnd.toIso8601String(),
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
