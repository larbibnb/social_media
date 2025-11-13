import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repo.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media/features/auth/presentation/views/authview.dart';
import 'package:social_media/features/home/presentation/views/home_view.dart';
import 'package:social_media/features/onboarding/presentation/views/onboarding.dart';
import 'package:social_media/features/post/data/post_repo_imp.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
import 'package:social_media/features/profile/data/firebase_profile_data.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/search/data/search_repo_imp.dart';
import 'package:social_media/features/search/domain/search_repo.dart';
import 'package:social_media/features/search/presentation/cubit/search_cubit.dart';
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
 -StorageCubit
 -PostCubit
 -SearchCubit
 -ProfileCubit
 -SettingsCubit
Chek AuthState
 -Authenticated ==> HomeScreen
 -UnAuthenticated ==> Authscreen

*/

class MyApp extends StatelessWidget {
  AuthRepo authRepo = FirebaseAuthRepo();
  ProfileRepo profileRepo = FirebaseProfileRepo(FirebaseFirestore.instance);
  PostRepo postRepo = PostRepoImp();
  StorageRepo storageRepo = FirebaseStorageRepo();
  SearchRepo searchRepo = SearchRepoImpl(firestore: FirebaseFirestore.instance);
  final sharedPreferences = SharedPreferences.getInstance();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authRepo)..chekAuth()),
        BlocProvider(create: (context) => ProfileCubit(profileRepo)),
        BlocProvider(create: (context) => PostCubit(postRepo, storageRepo)),
        BlocProvider(create: (context) => SearchCubit(searchRepo)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            print(state);
            if (state is Authenticated) {
              // Read the onboarding flag asynchronously and render the
              // appropriate initial screen. Use a FutureBuilder so we wait
              // for SharedPreferences to be ready instead of relying on a
              // quickly-assigned local variable (which caused a race and
              // always returned the onboarding screen).
              return FutureBuilder<bool>(
                future: sharedPreferences.then(
                  (prefs) => prefs.getBool('shouldShowOnboarding') ?? true,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final shouldShowOnboarding = snapshot.data!;
                  if (shouldShowOnboarding) {
                    return Onboarding(userId: state.appUser.uid);
                  }
                  return const HomeView();
                },
              );
            } else if (state is UnAuthenticated) {
              return const AuthView();
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
