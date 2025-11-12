class AppUser {
  final String uid;
  final String? displayName;
  final String? userName;
  final Gender? gender;
  final String email;
  final String? createdAt;

  AppUser({
    required this.uid,
    this.displayName,
    this.userName,
    this.gender,
    required this.email,
    this.createdAt,
  });

  //appuser to json format
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'userName': userName,
      'gender': gender?.name,
      'email': email,
      'createdAt': createdAt,
    };
  }

  //json to appuser format
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      displayName: json['displayName'],
      userName: json['userName'],
      gender:
          json['gender'] != null
              ? Gender.values.firstWhere(
                (e) => e.name == json['gender'],
                orElse: () => Gender.male,
              )
              : null,
      email: json['email'],
      createdAt: json['createdAt'],
    );
  }
}

enum Gender { male, female }
