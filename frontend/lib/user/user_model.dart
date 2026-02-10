import 'package:flutter_application/user/user_type.dart';

class User {
  final int id;
  final String name;
  final double height;
  final double weight;
  final UserType userType;
  final bool differentDays;

  User({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.userType,
    required this.differentDays
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      userType: json['userType'],
      differentDays: json['differentDays'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'userType': userType,
      'differentDays': differentDays,
    };
  }
}