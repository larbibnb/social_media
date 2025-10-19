class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.createdAt,
  });

  //appuser to json format
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt
    };
  }

  //json to appuser format
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      createdAt: json['createdAt'],
    );
  }
}