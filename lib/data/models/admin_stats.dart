import 'package:a4_iot/domain/entities/admin_stats.dart';

/// Modèles pour les données administrateur avec mapping depuis Supabase

/// Modèle pour AdminDashboardStats
class AdminDashboardStatsModel extends AdminDashboardStats {
  AdminDashboardStatsModel({
    required super.totalStudents,
    required super.presentToday,
    required super.absentToday,
    required super.lateToday,
    required super.attendanceRate,
  });

  factory AdminDashboardStatsModel.fromMap(Map<String, dynamic> map) {
    return AdminDashboardStatsModel(
      totalStudents: map['total_students'] ?? 0,
      presentToday: map['present_today'] ?? 0,
      absentToday: map['absent_today'] ?? 0,
      lateToday: map['late_today'] ?? 0,
      attendanceRate: (map['attendance_rate'] ?? 0).toDouble(),
    );
  }
}

/// Modèle pour CourseAttendanceStats
class CourseAttendanceStatsModel extends CourseAttendanceStats {
  CourseAttendanceStatsModel({
    required super.courseId,
    required super.courseName,
    required super.instructorName,
    required super.startTime,
    required super.endTime,
    required super.totalStudents,
    required super.presentStudents,
    required super.absentStudents,
    required super.lateStudents,
    required super.attendanceRate,
  });

  factory CourseAttendanceStatsModel.fromMap(Map<String, dynamic> map) {
    return CourseAttendanceStatsModel(
      courseId: map['course_id']?.toString() ?? '',
      courseName: map['course_name']?.toString() ?? 'Sans nom',
      instructorName: map['instructor_name']?.toString() ?? 'Inconnu',
      startTime: map['start_time'] != null 
          ? DateTime.parse(map['start_time'].toString())
          : DateTime.now(),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'].toString())
          : DateTime.now(),
      totalStudents: map['total_students'] ?? 0,
      presentStudents: map['present_students'] ?? 0,
      absentStudents: map['absent_students'] ?? 0,
      lateStudents: map['late_students'] ?? 0,
      attendanceRate: (map['attendance_rate'] ?? 0).toDouble(),
    );
  }
}

/// Modèle pour StudentAttendance
class StudentAttendanceModel extends StudentAttendance {
  StudentAttendanceModel({
    required super.studentId,
    required super.studentName,
    required super.studentEmail,
    super.studentPromo,
    required super.status,
    super.checkInTime,
    super.delayMinutes,
    super.courseId,
    super.courseName,
  });

  factory StudentAttendanceModel.fromMap(Map<String, dynamic> map) {
    // Parser le statut
    AttendanceStatus status;
    final statusStr = map['status']?.toString().toLowerCase() ?? 'absent';
    if (statusStr == 'present') {
      status = AttendanceStatus.present;
    } else if (statusStr == 'late') {
      status = AttendanceStatus.late;
    } else {
      status = AttendanceStatus.absent;
    }

    return StudentAttendanceModel(
      studentId: map['student_id']?.toString() ?? '',
      studentName: map['student_name']?.toString() ?? 'Inconnu',
      studentEmail: map['student_email']?.toString() ?? '',
      studentPromo: map['student_promo']?.toString(),
      status: status,
      checkInTime: map['check_in_time'] != null
          ? DateTime.parse(map['check_in_time'].toString())
          : null,
      delayMinutes: map['delay_minutes'],
      courseId: map['course_id']?.toString(),
      courseName: map['course_name']?.toString(),
    );
  }
}

/// Modèle pour AdminNotification
class AdminNotificationModel extends AdminNotification {
  AdminNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    super.isRead,
    super.metadata,
  });

  factory AdminNotificationModel.fromMap(Map<String, dynamic> map) {
    // Parser le type
    NotificationType type;
    final typeStr = map['type']?.toString() ?? 'systemAlert';
    switch (typeStr) {
      case 'lateStudent':
        type = NotificationType.lateStudent;
        break;
      case 'absentStudent':
        type = NotificationType.absentStudent;
        break;
      case 'courseStarting':
        type = NotificationType.courseStarting;
        break;
      case 'courseEnding':
        type = NotificationType.courseEnding;
        break;
      default:
        type = NotificationType.systemAlert;
    }

    return AdminNotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: type,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }
}

/// Modèle pour AdminCourse
class AdminCourseModel extends AdminCourse {
  AdminCourseModel({
    required super.courseId,
    required super.courseName,
    required super.instructorName,
    required super.instructorId,
    required super.startTime,
    required super.endTime,
    required super.roomName,
    super.roomId,
    required super.promoName,
    super.promoId,
    required super.totalStudents,
    super.presentStudents,
    super.attendanceRate,
  });

  factory AdminCourseModel.fromMap(Map<String, dynamic> map) {
    return AdminCourseModel(
      courseId: map['course_id']?.toString() ?? '',
      courseName: map['course_name']?.toString() ?? 'Sans nom',
      instructorName: map['instructor_name']?.toString() ?? 'Inconnu',
      instructorId: map['instructor_id']?.toString() ?? '',
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'].toString())
          : DateTime.now(),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'].toString())
          : DateTime.now(),
      roomName: map['room_name']?.toString() ?? 'Salle inconnue',
      roomId: map['room_id']?.toString(),
      promoName: map['promo_name']?.toString() ?? 'Promo inconnue',
      promoId: map['promo_id']?.toString(),
      totalStudents: map['total_students'] ?? 0,
      presentStudents: map['present_students'] ?? 0,
      attendanceRate: (map['attendance_rate'] ?? 0).toDouble(),
    );
  }
}
