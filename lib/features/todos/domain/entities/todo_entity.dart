import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final bool completed;
  final bool isPendingSync;

  const TodoEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.isPendingSync = false,
  });

  TodoEntity copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? isPendingSync,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'completed': completed,
        'isPendingSync': isPendingSync,
      };

  factory TodoEntity.fromJson(Map<String, dynamic> json) => TodoEntity(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        completed: json['completed'] as bool,
        isPendingSync: json['isPendingSync'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, userId, title, completed, isPendingSync];
}
