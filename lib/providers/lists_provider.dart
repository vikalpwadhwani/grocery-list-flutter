import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/list_model.dart';

class ListsState {
  final bool isLoading;
  final List<GroceryListModel> lists;
  final String? error;

  ListsState({
    this.isLoading = false,
    this.lists = const [],
    this.error,
  });

  ListsState copyWith({
    bool? isLoading,
    List<GroceryListModel>? lists,
    String? error,
  }) {
    return ListsState(
      isLoading: isLoading ?? this.isLoading,
      lists: lists ?? this.lists,
      error: error,
    );
  }
}

class ListsNotifier extends StateNotifier<ListsState> {
  final ApiClient _apiClient;

  ListsNotifier(this._apiClient) : super(ListsState());

  Future<void> fetchLists() async {
    print('📋 [ListsProvider] fetchLists() called');
    print('📋 [ListsProvider] Current lists count: ${state.lists.length}');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get(ApiConstants.lists);

      if (response.data['success']) {
        final lists = (response.data['data']['lists'] as List)
            .map((json) => GroceryListModel.fromJson(json))
            .toList();

        print('📋 [ListsProvider] Fetched ${lists.length} lists from API');
        state = state.copyWith(isLoading: false, lists: lists);
        print('📋 [ListsProvider] State updated, lists count: ${state.lists.length}');
      }
    } catch (e) {
      print('📋 [ListsProvider] Error fetching lists: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> joinList(String inviteCode) async {
    print('📋 [ListsProvider] joinList() called');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.post(
        ApiConstants.joinList,
        data: {'inviteCode': inviteCode},
      );
      state = state.copyWith(isLoading: false);
      return response.data['success'] == true;
    } catch (e) {
      print('📋 [ListsProvider] Error joining list: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteList(String listId) async {
    print('📋 [ListsProvider] deleteList() called for: $listId');

    final originalLists = List<GroceryListModel>.from(state.lists);
    state = state.copyWith(
      lists: state.lists.where((l) => l.id != listId).toList(),
    );

    try {
      final response = await _apiClient.delete('${ApiConstants.lists}/$listId');
      if (response.data['success']) {
        print('📋 [ListsProvider] List deleted successfully');
        return true;
      }
      state = state.copyWith(lists: originalLists);
      return false;
    } catch (e) {
      print('📋 [ListsProvider] Error deleting list: $e');
      state = state.copyWith(lists: originalLists, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final listsProvider = StateNotifierProvider<ListsNotifier, ListsState>((ref) {
  return ListsNotifier(ApiClient());
});