
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String ownerId;
  final String description;
  final List<String> images;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.images,
    required this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      ownerId: json['ownerId'],
      description: json['description'],
      images: List<String>.from(json['images']),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'description': description,
      'images': images,
      'timestamp':Timestamp.fromDate(timestamp),
    };
  }
  Post copyWith({
    String? id,
    String? ownerId,
    String? description,
    List<String>? images,
    DateTime? timestamp,
  }) {
    return Post(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        description: description ?? this.description,
        images: images ?? this.images,
        timestamp: timestamp ?? this.timestamp);
  }
}
