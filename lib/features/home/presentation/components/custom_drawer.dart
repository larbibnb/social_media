import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/home/presentation/components/drawer_tiles.dart';
import 'package:social_media/features/profile/presentation/views/profile_view.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              DrawerTiles(title: 'SEARCH', icon: Icons.search, onTap: () {}),
              SizedBox(height: 25),
              DrawerTiles(title: 'HOME', icon: Icons.home, onTap: () {}),
              DrawerTiles(
                title: 'PROFILE',
                icon: Icons.person,
                onTap: () {
                  final authCubit = context.read<AuthCubit>();
                  final currentUser = authCubit.currentUser;
                  if (currentUser != null) {
                    final uid = currentUser.uid;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileView(uid: uid),
                      ),
                    );
                  }
                },
              ),
              DrawerTiles(
                title: 'SETTINGS',
                icon: Icons.settings,
                onTap: () {},
              ),
              Spacer(),
              DrawerTiles(
                title: 'LOGOUT',
                icon: Icons.logout,
                onTap: () {
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
