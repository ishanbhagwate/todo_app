import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/offline_banner.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/todo_search_bar.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Todos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                if (state.pendingSyncCount > 0)
                  Text(
                    '${state.pendingSyncCount} pending sync',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listenWhen: (prev, curr) =>
            curr.status == TodoStatus.failure &&
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              OfflineBanner(isOffline: !state.isOnline),
              const TodoSearchBar(),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/todos/add'),
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TodoState state) {
    if (state.status == TodoStatus.loading && state.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == TodoStatus.failure && state.todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<TodoBloc>().add(const LoadTasks()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.filteredTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No todos matching "${state.searchQuery}"'
                  : 'No todos yet. Tap + to add one!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TodoBloc>().add(const RefreshTasks());
        await context.read<TodoBloc>().stream.firstWhere(
          (s) => s.status != TodoStatus.loading,
        );
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.filteredTodos.length,
        separatorBuilder: (ctx, idx) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return TodoListItem(todo: state.filteredTodos[index]);
        },
      ),
    );
  }
}
