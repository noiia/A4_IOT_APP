// lib/presentation/widget/course_list.dart

import 'package:flutter/material.dart';
import 'package:a4_iot/domain/entities/courses.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class CourseList extends StatelessWidget {
  final List<HomeCourses> courses;
  final String? bleNextClassJson;

  const CourseList({super.key, required this.courses, this.bleNextClassJson});

  List<HomeCourses> get _displayCourses {
    if (bleNextClassJson == null || bleNextClassJson!.isEmpty) {
      return courses;
    }

    try {
      final decoded = jsonDecode(bleNextClassJson!);
      if (decoded is! List) return courses;

      return decoded
          .whereType<Map<String, dynamic>>()
          .map<HomeCourses>(
            (json) => HomeCourses(
              id: (json['id'] ?? '').toString(),
              courseName:
                  json['course_name'] ?? json['name'] ?? 'Cours inconnu',
              instructor: json['instructor'] ?? 'Professeur',
              room:
                  json['course_rooms']?['name'] ??
                  json['room'] ??
                  'Salle non définie',
              reservationStart: _parseTime(
                json['reservation_start'] ??
                    json['start_time'] ??
                    json['courseschedules']?['start_time'],
              ),
              reservationEnd: _parseTime(
                json['reservation_end'] ??
                    json['end_time'] ??
                    json['courseschedules']?['end_time'],
              ),
            ),
          )
          .toList();
    } catch (_) {
      return courses;
    }
  }

  DateTime _parseTime(dynamic value) {
    final timeStr = (value ?? '14:00').toString();
    try {
      if (timeStr.contains('T')) {
        final part = timeStr.split('T')[1];
        final hhmm = part.split('.').first.substring(0, 5);
        return DateFormat('HH:mm').parse(hhmm);
      }
      return DateFormat('HH:mm').parse(timeStr);
    } catch (_) {
      return DateFormat('HH:mm').parse('14:00');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCourses = _displayCourses;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayCourses.length,
        itemBuilder: (context, index) {
          final course = displayCourses[index];
          return ListTile(
            title: Text(course.courseName),
            subtitle: Text(
              '${course.room} - ${course.instructor} - '
              '${DateFormat('HH:mm').format(course.reservationStart)}, '
              'à ${DateFormat('HH:mm').format(course.reservationEnd)}',
            ),
          );
        },
      ),
    );
  }
}
