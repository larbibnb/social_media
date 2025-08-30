import 'package:social_media/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String? bio;
  final String? profilePicUrl;

  ProfileUser({
    required super.uid,
    required super.name,
    required super.email,
    this.bio,
    this.profilePicUrl =
        'https://sm.ign.com/t/ign_pk/cover/a/avatar-gen/avatar-generations_rpge.600.jpg',
  });

  ProfileUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? bio,
    String? profilePicUrl,
  }) {
    return ProfileUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }

  //json to profileUser format
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profilePicUrl:
          json['profilePicUrl'] ??
          'https://sm.ign.com/t/ign_pk/cover/a/avatar-gen/avatar-generations_rpge.600.jpg',
    );
  }
  //profileUser to json format
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
    };
  }
}
