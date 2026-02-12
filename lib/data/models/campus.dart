import 'package:a4_iot/domain/entities/campus.dart';

class CampusModel extends Campus {
  CampusModel({
    required super.id,
    required super.name,
    required super.city,
    required super.address,
    required super.zipCode,
    required super.createdAt,
  });

  factory CampusModel.fromMap(Map<String, dynamic> map) {
    return CampusModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Inconnu',
      city: map['city']?.toString() ?? 'Ville inconnue',
      address: map['address']?.toString() ?? 'Adresse inconnue',
      zipCode: map['zip_code']?.toString() ?? '00000',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "city": city,
    "address": address,
    "zip_code": zipCode,
    "created_at": createdAt,
  };
}
