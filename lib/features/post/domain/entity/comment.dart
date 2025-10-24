import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String ownerId;
  final String ownerName;
  final String postId;
  final String description;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.postId,
    required this.description,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      postId: json['postId'],
      description: json['description'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'postId': postId,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
