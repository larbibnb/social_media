import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/search/domain/search_repo.dart';
import 'package:social_media/features/search/presentation/cubit/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo _searchRepo;

  SearchCubit(this._searchRepo) : super(SearchInitial());

  Future<void> searchUsers(String? query) async {
    if (query == null || query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    try {
      emit(SearchLoading());
      final users = await _searchRepo.searchUsers(query);
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
