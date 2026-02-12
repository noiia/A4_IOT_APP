class Courses {
  final String id;
  final String courseName;
  final String instructorId;
  final String roomId;
  final DateTime createdAt;
  final DateTime start;
  final DateTime end;
  final String room;
  final String promsId;

  Courses({
    required this.id,
    required this.courseName,
    required this.instructorId,
    required this.roomId,
    required this.createdAt, 
    required this.start,
    required this.end,
    required this.room,
    required this.promsId,
  });
}

class HomeCourses {
  final String id;
  final String courseName;
  final String instructor;
  final String room;
  final DateTime reservationStart;
  final DateTime reservationEnd;
  HomeCourses({
    required this.id,
    required this.courseName,
    required this.instructor,
    required this.room,
    required this.reservationStart,
    required this.reservationEnd,
  });
}
