import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
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
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final interestsController = TextEditingController();
  final genderValue = ValueNotifier<String>('');
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
    final displayName = nameController.text.trim();
    final location = locationController.text.trim();
    final bio = bioController.text.trim();
    final updatedprofileUser = profileUser.copyWith(
      displayName: displayName,
      location: location,
      bio: bio,
    );
    context.read<ProfileCubit>().updateProfileUser(
      updatedprofileUser,
      pickedFile: pickedFile,
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.displayName ?? '';
    locationController.text = widget.user.location ?? '';
    genderValue.value = widget.user.gender?.name ?? Gender.male.name;
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Your Profile',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Display Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'e.g., John Doe',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Whats your sex?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Select your sex',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        genderValue.value = value!;
                                      });
                                    },
                                    value: genderValue.value,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'male',
                                        child: Text('Male'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'female',
                                        child: Text('Female'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Where are you from?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode: true,
                                        onSelect: (Country country) {
                                          setState(() {
                                            locationController.text =
                                                '${country.flagEmoji} ${country.name}';
                                          });
                                        },
                                      );
                                    },
                                    controller: locationController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText:
                                          locationController.text.isNotEmpty
                                              ? locationController.text
                                              : 'Select Country',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: bioController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'Write a short bio about yourself',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
