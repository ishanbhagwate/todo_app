import 'package:azodha_assignment/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/todo_model.dart';

@injectable
class TodoRemoteDataSource {
  final Dio _dio;

  TodoRemoteDataSource(this._dio);

  Future<List<TodoModel>> fetchTodos() async {
    final response = await _dio.get(ApiConstants.todos);
    return (response.data as List)
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TodoModel> addTodo(String title) async {
    try {
      final response = await _dio.post(
        ApiConstants.todos,
        data: {'title': title, 'completed': false, 'userId': 1},
      );
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized');
      }
      rethrow;
    }
  }

  Future<TodoModel> completeTodo(int id) async {
    final response = await _dio.patch(
      ApiConstants.todoById(id),
      data: {'completed': true},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    // JSONPlaceholder returns partial data for IDs > 200 (POST-created todos)
    return TodoModel(
      id: (data['id'] as int?) ?? id,
      userId: (data['userId'] as int?) ?? 1,
      title: (data['title'] as String?) ?? '',
      completed: (data['completed'] as bool?) ?? true,
    );
  }

  Future<void> deleteTodo(int id) async {
    await _dio.delete(ApiConstants.todoById(id));
  }
}
