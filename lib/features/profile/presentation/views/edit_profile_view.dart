import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class EditProfileView extends StatefulWidget {
  final ProfileUser user;
  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  PlatformFile? pickedFile;
  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pickedFile = result.files.first;
        });
      }
    } catch (e) {
      // Handle the error gracefully
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void updateProfile(ProfileUser profileUser) {
    final name = nameController.text.trim();
    final bio = bioController.text.trim();
    final updatedprofileUser = profileUser.copyWith(name: name, bio: bio);
    context.read<ProfileCubit>().updateProfileUser(
      updatedprofileUser,
      pickedFile,
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    bioController.text = widget.user.bio ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Profile'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    updateProfile(widget.user);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check),
                ),
              ],
            ),
            body: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Name'),
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(hintText: 'Bio'),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return Scaffold(
            body: Center(child: Text((state as ProfileError).error)),
          );
        }
      },
    );
  }
}
