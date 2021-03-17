import 'dart:convert';

import 'package:flutter/foundation.dart';

class ChatModel {
  final String user;
  final String message;
  final String date;
  ChatModel({@required this.user, @required this.message, @required this.date});

  ChatModel copyWith({
    String user,
    String message,
  }) {
    return ChatModel(
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {'user': user, 'message': message, 'date': date};
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
        user: map['user'], message: map['message'], date: map['date']);
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source));

  @override
  String toString() => 'ChatModel(user: $user, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatModel && other.user == user && other.message == message;
  }

  @override
  int get hashCode => user.hashCode ^ message.hashCode;
}
