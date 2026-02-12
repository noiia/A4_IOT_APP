/// Entités pour les statistiques et données administrateur

/// Statistiques du tableau de bord admin
class AdminDashboardStats {
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double attendanceRate;

  AdminDashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.attendanceRate,
  });
}

/// Statut de présence d'un étudiant
enum AttendanceStatus {
  present,
  absent,
  late,
}

/// Statistiques de présence pour un cours
class CourseAttendanceStats {
  final String courseId;
  final String courseName;
  final String instructorName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;
  final int lateStudents;
  final double attendanceRate;

  CourseAttendanceStats({
    required this.courseId,
    required this.courseName,
    required this.instructorName,
    required this.startTime,
    required this.endTime,
    required this.totalStudents,
    required this.presentStudents,
    required this.absentStudents,
    required this.lateStudents,
    required this.attendanceRate,
  });
}

/// Présence d'un étudiant pour un cours
class StudentAttendance {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentPromo;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final int? delayMinutes;
  final String? courseId;
  final String? courseName;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentPromo,
    required this.status,
    this.checkInTime,
    this.delayMinutes,
    this.courseId,
    this.courseName,
  });
}

/// Notification administrateur
class AdminNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });
}

/// Types de notifications
enum NotificationType {
  lateStudent,
  absentStudent,
  courseStarting,
  courseEnding,
  systemAlert,
}

/// Cours administrateur (avec infos supplémentaires)
class AdminCourse {
  final String courseId;
  final String courseName;
  final String instructorName;
  final String instructorId;
  final DateTime startTime;
  final DateTime endTime;
  final String roomName;
  final String? roomId;
  final String promoName;
  final String? promoId;
  final int totalStudents;
  final int presentStudents;
  final double attendanceRate;

  AdminCourse({
    required this.courseId,
    required this.courseName,
    required this.instructorName,
    required this.instructorId,
    required this.startTime,
    required this.endTime,
    required this.roomName,
    this.roomId,
    required this.promoName,
    this.promoId,
    required this.totalStudents,
    this.presentStudents = 0,
    this.attendanceRate = 0.0,
  });
}
