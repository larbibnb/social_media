import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo _postRepo;
  final StorageRepo _storageRepo;
  PostCubit(this._postRepo, this._storageRepo) : super(PostInitial());


  Future<void> fetchPosts() async {
    emit(PostLoading());
    try {
      final posts = await _postRepo.fetchPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
  Future<void> createOrUpdatePost(Post post,{List<String>? pathImages}) async {
    try {
      emit(PostLoading());
       final uploadedUrls = <String>[];
       if(pathImages != null && pathImages.isNotEmpty){
        
         post.images.addAll(uploadedUrls);
         log(post.images.toString());
       }
      _postRepo.createOrUpdatePost(post);
      fetchPosts();
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await _postRepo.deletePost(postId);
      emit(PostInitial());
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}

