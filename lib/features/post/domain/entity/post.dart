import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';

class Post {
  final String id;
  final String ownerId;
  final String description;
  final List<String> images;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.images,
    this.likes = const [],
    this.comments = const [],
    required this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json, {List<Comment>? comments}) {
    return Post(
      id: json['id'],
      ownerId: json['ownerId'],
      description: json['description'],
      images: List<String>.from(json['images'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments ?? [],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'description': description,
      'images': images,
      'likes': likes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  Post copyWith({
    String? id,
    String? ownerId,
    String? description,
    List<String>? images,
    List<String>? likes,
    List<Comment>? comments,
    DateTime? timestamp,
  }) {
    return Post(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
