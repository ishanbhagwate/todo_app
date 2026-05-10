import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/todo_entity.dart';
import '../../../../core/constants/hive_constants.dart';

part 'todo_model.g.dart';

@HiveType(typeId: HiveConstants.todoModelTypeId)
class TodoModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  bool isPendingSync;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.isPendingSync = false,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as int,
        userId: json['userId'] as int? ?? 1,
        title: json['title'] as String,
        completed: json['completed'] as bool,
        isPendingSync: json['isPendingSync'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'completed': completed,
        'isPendingSync': isPendingSync,
      };

  TodoEntity toEntity() => TodoEntity(
        id: id,
        userId: userId,
        title: title,
        completed: completed,
        isPendingSync: isPendingSync,
      );

  static TodoModel fromEntity(TodoEntity entity) => TodoModel(
        id: entity.id,
        userId: entity.userId,
        title: entity.title,
        completed: entity.completed,
        isPendingSync: entity.isPendingSync,
      );
}
