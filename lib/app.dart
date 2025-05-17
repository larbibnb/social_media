import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repo.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media/features/auth/presentation/views/authview.dart';
import 'package:social_media/features/posts/presentation/views/home_view.dart';
import 'package:social_media/themes/light_mode.dart';

/*
app root level 
____________________________________

Repositories for the database
 -Firebase

Cubits for the business logic
 -AuthCubit
 -PostCubit
 -CommentCubit
 -LikeCubit
 -SearchCubit
 -NotificationCubit
 -ProfileCubit
 -SettingsCubit
 -ChatCubit
 -CallCubit
 -VideoCubit
 -AudioCubit
 -ImageCubit
 -FileCubit
 -LocationCubit
 -CameraCubit
 -GalleryCubit
Chek AuthState
 -Authenticated ==> HomeScreen
 -UnAuthenticated ==> Authscreen

*/

class MyApp extends StatelessWidget {
  AuthRepo authRepo = FirebaseAuthRepo();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepo)..chekAuth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: BlocConsumer <AuthCubit, AuthState>(
        builder: (context, state) {
          print(state);
          if (state is Authenticated) {
            return const HomeView();
          } else if (state is UnAuthenticated) {
            return const Authscreen();
          } else if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text((state as AuthError).error),
            );
          }
        }, 
        listener: (context, state) {
        },
        ),
      ),
    );
  }
}
