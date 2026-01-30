import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/network/socket_service.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';
import '../../widgets/grocery_item_tile.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_item_dialog.dart';
import 'edit_item_dialog.dart';
import 'share_list_dialog.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(listDetailProvider(widget.listId).notifier).fetchListDetails();
    });
    _socketService.joinList(widget.listId);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.onItemAdded((data) {
      if (data['listId'] == widget.listId) {
        final item = ItemModel.fromJson(data['item']);
        ref.read(listDetailProvider(widget.listId).notifier).onItemAdded(item);
      }
    });

    _socketService.onItemToggled((data) {
      if (data['listId'] == widget.listId) {
        final item = ItemModel.fromJson(data['item']);
        ref.read(listDetailProvider(widget.listId).notifier).onItemToggled(item);
      }
    });

    _socketService.onItemUpdated((data) {
      if (data['listId'] == widget.listId) {
        final item = ItemModel.fromJson(data['item']);
        ref.read(listDetailProvider(widget.listId).notifier).onItemToggled(item);
      }
    });

    _socketService.onItemDeleted((data) {
      if (data['listId'] == widget.listId) {
        ref.read(listDetailProvider(widget.listId).notifier).onItemDeleted(data['itemId']);
      }
    });
  }

  @override
  void dispose() {
    _socketService.leaveList(widget.listId);
    _socketService.removeListeners();
    super.dispose();
  }

  Future<void> _refreshList() async {
    await ref.read(listDetailProvider(widget.listId).notifier).fetchListDetails();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(listId: widget.listId),
    );
  }

  void _showEditItemDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => EditItemDialog(
        listId: widget.listId,
        item: item,
      ),
    );
  }

  void _showShareDialog() {
    final state = ref.read(listDetailProvider(widget.listId));
    if (state.list != null) {
      showDialog(
        context: context,
        builder: (context) => ShareListDialog(
          inviteCode: state.list!.inviteCode,
          listName: state.list!.name,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listDetailProvider(widget.listId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: _buildBody(state),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(ListDetailState state) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.list?.name ?? 'Loading...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.items.isNotEmpty)
            Text(
              '${state.items.where((i) => i.isChecked).length}/${state.items.length} completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share List',
          onPressed: _showShareDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(ListDetailState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingWidget(message: 'Loading items...');
    }

    if (state.items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_basket_outlined,
        title: 'No Items Yet',
        subtitle: 'Add items to your grocery list.',
        buttonText: 'Add Item',
        onButtonPressed: _showAddItemDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshList,
      color: AppColors.primary,
      child: _buildItemsList(state),
    );
  }

  Widget _buildItemsList(ListDetailState state) {
    final uncheckedItems = state.items.where((i) => !i.isChecked).toList();
    final checkedItems = state.items.where((i) => i.isChecked).toList();

    return CenteredContent(
      maxWidth: 700,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildProgressBar(state),
          
          const SizedBox(height: 16),
          
          if (uncheckedItems.isNotEmpty) ...[
            _buildSectionHeader('To Buy', uncheckedItems.length),
            ...uncheckedItems.map((item) => _buildItemTile(item)),
          ],
          
          if (checkedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader('Completed', checkedItems.length),
            ...checkedItems.map((item) => _buildItemTile(item)),
          ],
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ListDetailState state) {
    final total = state.items.length;
    final checked = state.items.where((i) => i.isChecked).length;
    final progress = total > 0 ? checked / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.success : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ItemModel item) {
    return GroceryItemTile(
      item: item,
      onToggle: () {
        ref.read(listDetailProvider(widget.listId).notifier).toggleItem(item.id);
      },
      onEdit: () => _showEditItemDialog(item),
      onDelete: () {
        ref.read(listDetailProvider(widget.listId).notifier).deleteItem(item.id);
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddItemDialog,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }
}