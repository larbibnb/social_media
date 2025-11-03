import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
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
              title: const Text('Edit Profile'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    updateProfile(widget.user);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile picture + pick button
                  _ProfilePicture(
                    profileUrl: widget.user.profilePicUrl,
                    pickedFile: pickedFile,
                    onPick: pickImage,
                  ),
                  const SizedBox(height: 20),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bioController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              updateProfile(widget.user);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            body: Center(child: Text((state as ProfileError).error)),
          );
        }
      },
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  final String? profileUrl;
  final PlatformFile? pickedFile;
  final VoidCallback onPick;

  const _ProfilePicture({
    this.profileUrl,
    this.pickedFile,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final radius = 64.0;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                  child:
                      pickedFile != null && pickedFile!.path != null
                          ? Image.file(
                            File(pickedFile!.path!),
                            fit: BoxFit.cover,
                          )
                          : (profileUrl != null && profileUrl!.isNotEmpty
                              ? Image.network(profileUrl!, fit: BoxFit.cover)
                              : Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.person, size: 48),
                                ),
                              )),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onPick,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Change'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
