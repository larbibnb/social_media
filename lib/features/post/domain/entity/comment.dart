class Comment {
  final String id;
  final String ownerId;
  final String postId;
  final String description;

  Comment({
    required this.id,
    required this.ownerId,
    required this.postId,
    required this.description,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['commentId'],
      ownerId: json['ownerId'],
      postId: json['postId'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'commentId': id,
      'ownerId': ownerId,
      'postId': postId,
      'description': description,
    };
  }
}
