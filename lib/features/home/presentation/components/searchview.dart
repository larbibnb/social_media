import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/presentation/views/profile_view.dart';
import 'package:social_media/features/search/presentation/cubit/search_cubit.dart';
import 'package:social_media/features/search/presentation/cubit/search_states.dart';

void showSearchSheet(BuildContext context) {
  final TextEditingController searchController = TextEditingController();
  final SearchCubit searchCubit = context.read<SearchCubit>();

  void onChanged(String query) {
    searchCubit.searchUsers(query);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 50,
        ),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
              ),
              onChanged: (value) {
                onChanged(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is SearchLoaded) {
                    // The state returns a list of ProfileUser objects
                    final users = state.users;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final name = user.displayName;
                        final email = user.email;
                        final image = user.profilePicUrl;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ProfileView(uid: user.uid);
                                },
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              // Use a null check for the image URL
                              backgroundImage:
                                  image != null ? NetworkImage(image) : null,
                            ),
                            title: Text(name!),
                            subtitle: Text(email),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No results found'));
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
