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
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>).cast<String>(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
