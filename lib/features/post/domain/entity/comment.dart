class Comment {
  final String id;
  final String ownerId;
  final String description;

  Comment({
    required this.id,
    required this.ownerId,
    required this.description,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['commentId'],
      ownerId: json['ownerId'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'commentId': id,
      'ownerId': ownerId,
      'description': description,
    };
  }
}
