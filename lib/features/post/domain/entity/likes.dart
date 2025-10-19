class Likes {
  final String postId;
  final String ownerId;
  final String uid;
  final DateTime timestamp;

  Likes({required this.postId,  required this.ownerId, required this.uid, required this.timestamp});

  factory Likes.fromJson(Map<String, dynamic> json) {
    return Likes(
      postId: json['postId'],
      ownerId: json['ownerId'],
      uid: json['uid'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'uid': uid,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
