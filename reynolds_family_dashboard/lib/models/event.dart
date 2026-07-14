import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? familyMemberId;
  final String memberName;
  final int colorValue;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.location,
    this.familyMemberId,
    this.memberName = 'Unknown',
    this.colorValue = 0xFF3F51B5,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      location: json['location'] as String?,
      familyMemberId: json['family_member_id'] as String?,
      memberName: (json['family_members'] as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown',
      colorValue: Colors.indigo.toARGB32(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location': location,
      'family_member_id': familyMemberId,
    };
  }
}
