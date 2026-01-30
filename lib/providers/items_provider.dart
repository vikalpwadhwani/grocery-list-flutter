import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/storage_service.dart';
import '../models/item_model.dart';
import '../models/list_model.dart';

class ListDetailState {
  final bool isLoading;
  final GroceryListModel? list;
  final List<ItemModel> items;
  final String? error;
  final List<String> recentlyAddedIds;

  ListDetailState({
    this.isLoading = false,
    this.list,
    this.items = const [],
    this.error,
    this.recentlyAddedIds = const [],
  });

  ListDetailState copyWith({
    bool? isLoading,
    GroceryListModel? list,
    List<ItemModel>? items,
    String? error,
    List<String>? recentlyAddedIds,
  }) {
    return ListDetailState(
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      items: items ?? this.items,
      error: error,
      recentlyAddedIds: recentlyAddedIds ?? this.recentlyAddedIds,
    );
  }
}

class ListDetailNotifier extends StateNotifier<ListDetailState> {
  final ApiClient _apiClient;
  final String listId;
  final String? _currentUserId;

  ListDetailNotifier(this._apiClient, this.listId)
      : _currentUserId = StorageService.getUserId(),
        super(ListDetailState());

  Future<void> fetchListDetails() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get('${ApiConstants.lists}/$listId');
      if (response.data['success']) {
        final list = GroceryListModel.fromJson(response.data['data']['list']);
        state = state.copyWith(
          isLoading: false,
          list: list,
          items: list.items ?? [],
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> addItem({
    required String name,
    int quantity = 1,
    String? unit,
  }) async {

    try {
      final response = await _apiClient.post(
        ApiConstants.listItems(listId),
        data: {
          'name': name,
          'quantity': quantity,
          'unit': unit,
        },
      );

      if (response.data['success']) {
        final newItem = ItemModel.fromJson(response.data['data']['item']);

        final exists = state.items.any((i) => i.id == newItem.id);

        if (!exists) {
          final newRecentIds = [...state.recentlyAddedIds, newItem.id];

          state = state.copyWith(
            items: [newItem, ...state.items],
            recentlyAddedIds: newRecentIds,
          );

          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              final updatedIds = state.recentlyAddedIds.where((id) => id != newItem.id).toList();
              state = state.copyWith(recentlyAddedIds: updatedIds);
            }
          });
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleItem(String itemId) async {
    final itemIndex = state.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return false;

    final originalItem = state.items[itemIndex];
    final toggledItem = originalItem.copyWith(isChecked: !originalItem.isChecked);

    final updatedItems = List<ItemModel>.from(state.items);
    updatedItems[itemIndex] = toggledItem;
    state = state.copyWith(items: updatedItems);

    try {
      final response = await _apiClient.patch(
        ApiConstants.toggleItem(listId, itemId),
      );

      if (response.data['success']) {
        final updatedItem = ItemModel.fromJson(response.data['data']['item']);
        state = state.copyWith(
          items: state.items.map((item) {
            if (item.id == itemId) return updatedItem;
            return item;
          }).toList(),
        );
        return true;
      } else {
        updatedItems[itemIndex] = originalItem;
        state = state.copyWith(items: updatedItems);
        return false;
      }
    } catch (e) {
      updatedItems[itemIndex] = originalItem;
      state = state.copyWith(items: updatedItems);
      return false;
    }
  }

  Future<bool> updateItem({
    required String itemId,
    String? name,
    int? quantity,
    String? unit,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateItem(listId, itemId),
        data: {
          if (name != null) 'name': name,
          if (quantity != null) 'quantity': quantity,
          if (unit != null) 'unit': unit,
        },
      );

      if (response.data['success']) {
        final updatedItem = ItemModel.fromJson(response.data['data']['item']);
        state = state.copyWith(
          items: state.items.map((item) {
            if (item.id == itemId) return updatedItem;
            return item;
          }).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    final itemIndex = state.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return false;

    final deletedItem = state.items[itemIndex];

    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );

    try {
      final response = await _apiClient.delete(
        ApiConstants.deleteItem(listId, itemId),
      );

      if (response.data['success']) {
        return true;
      } else {
        final items = List<ItemModel>.from(state.items);
        items.insert(itemIndex, deletedItem);
        state = state.copyWith(items: items);
        return false;
      }
    } catch (e) {
      final items = List<ItemModel>.from(state.items);
      items.insert(itemIndex, deletedItem);
      state = state.copyWith(items: items);
      return false;
    }
  }

  void onItemAdded(ItemModel item) {

    if (state.recentlyAddedIds.contains(item.id)) {
      return;
    }

    if (state.items.any((i) => i.id == item.id)) {
      return;
    }

    if (item.addedBy == _currentUserId) {
      return;
    }

    state = state.copyWith(items: [item, ...state.items]);
  }

  void onItemToggled(ItemModel item) {
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.id == item.id) return item;
        return i;
      }).toList(),
    );
  }

  void onItemDeleted(String itemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final listDetailProvider =
StateNotifierProvider.family<ListDetailNotifier, ListDetailState, String>(
      (ref, listId) {
    return ListDetailNotifier(ApiClient(), listId);
  },
);