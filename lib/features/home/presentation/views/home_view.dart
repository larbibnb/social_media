import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media/features/home/presentation/components/custom_drawer.dart';
import 'package:social_media/features/home/presentation/components/searchview.dart';
import 'package:social_media/features/post/presentation/views/addpost.dart';
import 'package:social_media/features/post/presentation/views/feedview.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Initialize the ProfileCubit with the current user's profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      final profileCubit = context.read<ProfileCubit>();
      if (authCubit.state is Authenticated) {
        final userId = (authCubit.state as Authenticated).appUser.uid;
        profileCubit.getProfileUser(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('Feed'),
        actions: [
          // Right-aligned rounded popup menu with soft tiles
          PopupMenuButton<String>(
            icon: Icon(Icons.add),
            padding: EdgeInsets.zero,
            offset: Offset(0, 50), // drop down slightly below the icon
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.grey.shade50,
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'post',
                    child: Container(
                      width: 160,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.post_add, color: Colors.blue),
                          ),
                          SizedBox(width: 12),
                          Text('Post', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'story',
                    child: Container(
                      width: 160,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.circle, color: Colors.purple),
                          ),
                          SizedBox(width: 12),
                          Text('Story', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'post') {
                // Navigate to post creation or handle post action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Addpost()),
                );
              } else if (value == 'story') {
                // Handle story action
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Story selected')));
              }
            },
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.send)),
        ],
      ),
      body: FeedView(),
    );
  }
}
