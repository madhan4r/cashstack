import 'package:equatable/equatable.dart';

/// Mirrors the backend's `NotificationResponseDto` — an in-app record of a
/// notification-worthy event (recurring due, budget threshold, household
/// invite, savings goal milestone/deadline, low balance), created
/// alongside (not instead of) the FCM push so this list stays complete even
/// when the push itself didn't reach a device.
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, String> data;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      data: (json['data'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, data, read, createdAt];
}
