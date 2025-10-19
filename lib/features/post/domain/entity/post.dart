import 'package:social_media/features/post/domain/entity/comment.dart';

class Post {
  final String id;
  final String ownerId;
  final String description;
  final List<String> images;
  final List<Comment> comments;
  final List<String> likes;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.images,
    this.comments = const [],
    this.likes = const [],
    required this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>).cast<String>(),
      comments: (json['comments'] as List<dynamic>).cast<Comment>(), 
      likes: (json['likes'] as List<dynamic>).cast<String>(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'description': description,
      'images': images,
      'comments': comments,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
