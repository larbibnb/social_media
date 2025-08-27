import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repo.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media/features/auth/presentation/views/authview.dart';
import 'package:social_media/features/home/presentation/views/home_view.dart';
import 'package:social_media/features/profile/data/firebase_profile_data.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/storage/data/firebase_storage_repo.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';
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
  ProfileRepo profileRepo = FirebaseProfileRepo();
  StorageRepo storageRepo = FirebaseStorageRepo();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authRepo)..chekAuth()),
        BlocProvider(create: (context) => ProfileCubit(profileRepo)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            print(state);
            if (state is Authenticated) {
              return const HomeView();
            } else if (state is UnAuthenticated) {
              return const Authscreen();
            } else if (state is AuthLoading) {
              return Scaffold(
                body: const Center(child: CircularProgressIndicator()),
              );
            } else {
              return Center(child: Text((state as AuthError).error));
            }
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
        ),
      ),
    );
  }
}
