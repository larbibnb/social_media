import 'package:social_media/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final List<String> followers;
  final List<String> following;
  final List<String> interests;
  final String? bio;
  final String? profilePicUrl;

  ProfileUser({
    required super.uid,
    required super.displayName,
    required super.userName,
    required super.location,
    required super.gender,
    required super.email,
    required super.createdAt,
    this.followers = const [],
    this.following = const [],
    this.interests = const [],
    this.bio,
    this.profilePicUrl =
        'https://sm.ign.com/t/ign_pk/cover/a/avatar-gen/avatar-generations_rpge.600.jpg',
  });

  ProfileUser copyWith({
    String? uid,
    String? displayName,
    String? userName,
    String? location,
    Gender? gender,
    String? email,
    String? createdAt,
    String? bio,
    String? profilePicUrl,
    List<String>? followers,
    List<String>? following,
    List<String>? interests,
  }) {
    return ProfileUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      userName: userName ?? this.userName,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      interests: interests ?? this.interests,
    );
  }

  //json to profileUser format
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      displayName: json['displayName'],
      userName: json['userName'],
      location: json['location'],
      gender:
          json['gender'] != null
              ? Gender.values.firstWhere(
                (e) => e.name == json['gender'],
                orElse: () => Gender.male,
              )
              : null,
      email: json['email'],
      createdAt: json['createdAt'],
      bio: json['bio'],
      profilePicUrl:
          json['profilePicUrl'] ??
          'https://sm.ign.com/t/ign_pk/cover/a/avatar-gen/avatar-generations_rpge.600.jpg',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
  //profileUser to json format
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'userName': userName,
      'location': location,
      'gender': gender?.name,
      'email': email,
      'createdAt': createdAt,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
      'followers': followers,
      'following': following,
      'interests': interests,
    };
  }
}
