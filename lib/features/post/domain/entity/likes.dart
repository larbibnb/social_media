class Likes {
  final String postId;
  final String ownerId;
  final String uid;

  Likes({required this.postId,  required this.ownerId, required this.uid,});

  factory Likes.fromJson(Map<String, dynamic> json) {
    return Likes(
      postId: json['postId'],
      ownerId: json['ownerId'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'uid': uid,
      'ownerId': ownerId,};
  }
  
}
