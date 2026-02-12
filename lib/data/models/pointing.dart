import 'package:a4_iot/domain/entities/pointing.dart';

class PointingModel extends Pointing {
  PointingModel({
    required super.id,
    required super.userBadgeId,
    required super.date,
  });

  factory PointingModel.fromMap(Map<String, dynamic> map) {
    return PointingModel(
      id: map['id']?.toString() ?? '',
      userBadgeId: map['user_badge_id']?.toString() ?? '',
      date: map['Date'] != null 
          ? DateTime.parse(map['Date'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "user_badge_id": userBadgeId,
    "Date": date,
  };
}
