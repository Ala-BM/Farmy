import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({required this.senderId, required this.text, required this.timestamp, required this.id});

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
