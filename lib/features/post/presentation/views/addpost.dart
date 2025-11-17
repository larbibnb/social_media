import 'dart:developer';
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';

class Addpost extends StatefulWidget {
  const Addpost({super.key});

  @override
  State<Addpost> createState() => _AddpostState();
}

class _AddpostState extends State<Addpost> {
  final TextEditingController _descController = TextEditingController();
  // Simple emoji list with labels (feelings)
  final List<Map<String, String>> _emojis = [
    {'emoji': '😀', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😍', 'label': 'Love'},
    {'emoji': '😮', 'label': 'Surprised'},
    {'emoji': '😡', 'label': 'Angry'},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  final List<String> _images = [];
  List<PlatformFile>? pickedFiles;
  Future<void> pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pickedFiles = result.files;
        });
        if (_images.isNotEmpty) _images.clear();
        if (pickedFiles != null && pickedFiles!.isNotEmpty) {
          for (var file in pickedFiles!) {
            _images.add(file.path!);
          }
        }
      }
    } catch (e) {
      // Handle the error gracefully
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _addPost() {
    final currentUser = context.read<AuthCubit>().currentUser;
    if (currentUser == null) return;
    final newpost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: currentUser.uid,
      description: _descController.text,
      images: [],
      timestamp: DateTime.now(),
    );
    if (pickedFiles != null && pickedFiles!.isNotEmpty) {
      log("ssssssss$_images");
      context.read<PostCubit>().createOrUpdatePost(
        newpost,
        pathImages: _images,
      );
    } else {
      context.read<PostCubit>().createOrUpdatePost(newpost);
    }
    Navigator.pop(context);
  }

  void _appendEmojiToDescription(String emoji, String label) {
    final current = _descController.text;
    final addition = '$emoji $label';
    final newText = current.isEmpty ? addition : '$current  $addition';
    _descController.text = newText;
    // place cursor at end
    _descController.selection = TextSelection.fromPosition(
      TextPosition(offset: _descController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: BlocConsumer<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return buildAddPostPage(context);
        },
        listener: (context, state) {
          if (state is PostError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is PostsLoaded) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Post added successfully')));
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  SingleChildScrollView buildAddPostPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: TextField(
              controller: _descController,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'What\'s on your mind?',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Images grid and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Photos', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: pickImages,
                icon: Icon(Icons.add_a_photo),
                label: Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _images.isEmpty
              ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('No images added')),
              )
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final url = _images[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(url),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (c, e, s) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image),
                              ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(index)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

          const SizedBox(height: 16),

          // Emoji picker row
          Text(
            'Feeling / Activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                final item = _emojis[idx];
                return GestureDetector(
                  onTap:
                      () => _appendEmojiToDescription(
                        item['emoji']!,
                        item['label']!,
                      ),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          item['emoji']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item['label']!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shadowColor: Colors.black,
              ),
              onPressed: () {
                _addPost();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  'Add Post',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
