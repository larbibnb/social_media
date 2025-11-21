import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/home/presentation/components/drawer_tiles.dart';
import 'package:social_media/features/home/presentation/components/searchview.dart';
import 'package:social_media/features/home/presentation/views/home_view.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';
import 'package:social_media/features/profile/presentation/views/profile_view.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late final AuthCubit authCubit;
  late final ProfileCubit profileCubit;
  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    profileCubit = context.read<ProfileCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: profileCubit,
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return CircularProgressIndicator();
        } else if (state is ProfileError) {
          return Text(state.error);
        } else if (state is ProfileLoaded) {
          final profileUser = state.profileUser;
          return Drawer(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child:
                            profileUser.profilePicUrl != null
                                ? CachedNetworkImage(
                                  imageUrl: profileUser.profilePicUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (c, u) => SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget:
                                      (c, u, e) => Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.error),
                                      ),
                                )
                                : Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Text(
                                      profileUser.displayName!.characters.first
                                          .toUpperCase(),
                                      style: TextStyle(fontSize: 36),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    DrawerTiles(
                      title: 'SEARCH',
                      icon: Icons.search,
                      onTap: () {
                        showSearchSheet(context);
                      },
                    ),
                    SizedBox(height: 25),
                    DrawerTiles(
                      title: 'HOME',
                      icon: Icons.home,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => HomeView()),
                        );
                      },
                    ),
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
        } else {
          return SizedBox();
        }
      },
    );
  }
}
