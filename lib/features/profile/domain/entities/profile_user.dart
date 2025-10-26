import 'package:social_media/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final List<String> followers;
  final List<String> following;
  final String? bio;
  final String? profilePicUrl;

  ProfileUser({
    required super.uid,
    required super.name,
    required super.email,
    required super.createdAt,
    this.followers = const [],
    this.following = const [],
    this.bio,
    this.profilePicUrl =
        'https://sm.ign.com/t/ign_pk/cover/a/avatar-gen/avatar-generations_rpge.600.jpg',
  });

  ProfileUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? createdAt,
    String? bio,
    String? profilePicUrl,
    List<String>? followers,
    List<String>? following,
  }) {
    return ProfileUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

  //json to profileUser format
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      createdAt: json['createdAt'],
      bio: json['bio'],
      profilePicUrl:
          json['profilePicUrl'] ??
          'https://sm.ign.com/t/ign_pk/cover/a/avatar-gen/avatar-generations_rpge.600.jpg',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }
  //profileUser to json format
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
      'followers': followers,
      'following': following,
    };
  }
}
