import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/network/socket_service.dart';
import '../../models/list_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lists_provider.dart';
import '../../widgets/grocery_list_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../auth/login_screen.dart';
import '../list/list_detail_screen.dart';
import '../list/create_list_dialog.dart';
import '../list/join_list_dialog.dart';
import '../list/share_list_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    SocketService().connect();
    _initialFetch();
  }

  @override
  void dispose() {
    SocketService().disconnect();
    super.dispose();
  }

  void _initialFetch() {
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      Future.microtask(() {
        ref.read(listsProvider.notifier).fetchLists();
      });
    }
  }

  Future<void> _refreshLists() async {
    await ref.read(listsProvider.notifier).fetchLists();
  }

  void _showCreateListDialog() async {

    final newList = await showDialog<GroceryListModel?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateListDialog(),
    );


    if (newList != null && mounted) {

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ListDetailScreen(listId: newList.id),
        ),
      );

      await _refreshLists();
    } else {
    }
  }

  void _showJoinListDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const JoinListDialog(),
    );

    if (result == true) {
      await _refreshLists();
    }
  }

  void _showShareDialog(String inviteCode, String listName) {
    showDialog(
      context: context,
      builder: (context) => ShareListDialog(
        inviteCode: inviteCode,
        listName: listName,
      ),
    );
  }

  Future<void> _deleteList(String listId, String listName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "$listName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(listsProvider.notifier).deleteList(listId);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _navigateToList(String listId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListDetailScreen(listId: listId),
      ),
    );
    await _refreshLists();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final listsState = ref.watch(listsProvider);


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(authState),
      body: _buildBody(listsState),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthState authState) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Grocery Lists',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (authState.user != null)
            Text(
              'Hello, ${authState.user!.name}',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: _refreshLists,
        ),
        IconButton(
          icon: const Icon(Icons.group_add),
          tooltip: 'Join a List',
          onPressed: _showJoinListDialog,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(ListsState listsState) {
    if (listsState.isLoading && listsState.lists.isEmpty) {
      return const LoadingWidget(message: 'Loading your lists...');
    }

    if (listsState.lists.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'No Grocery Lists Yet',
        subtitle: 'Create a new list or join an existing one.',
        buttonText: 'Create List',
        onButtonPressed: _showCreateListDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshLists,
      color: AppColors.primary,
      child: _buildListView(listsState),
    );
  }

  Widget _buildListView(ListsState listsState) {
    if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
      return _buildGridView(listsState);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: listsState.lists.length,
      itemBuilder: (context, index) {
        final list = listsState.lists[index];
        return GroceryListCard(
          list: list,
          onTap: () => _navigateToList(list.id),
          onShare: () => _showShareDialog(list.inviteCode, list.name),
          onDelete: () => _deleteList(list.id, list.name),
        );
      },
    );
  }

  Widget _buildGridView(ListsState listsState) {
    return GridView.builder(
      padding: Responsive.padding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: listsState.lists.length,
      itemBuilder: (context, index) {
        final list = listsState.lists[index];
        return GroceryListCard(
          list: list,
          onTap: () => _navigateToList(list.id),
          onShare: () => _showShareDialog(list.inviteCode, list.name),
          onDelete: () => _deleteList(list.id, list.name),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showCreateListDialog,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('New List', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}