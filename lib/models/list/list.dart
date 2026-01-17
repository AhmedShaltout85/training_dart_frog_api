import 'package:equatable/equatable.dart';

///TaskLists list map data source in-memory cache
Map<String, TaskList> taskListsDb = {};

//// TaskList model
class TaskList extends Equatable {
  ///List's constructor
  const TaskList({required this.id, required this.title});

  ///List's from json
  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  ///List's to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  ///List's copy with
  TaskList copyWith({
    String? id,
    String? title,
  }) {
    return TaskList(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  ///List's id
  final String id;

  ///List's title
  final String title;

  @override
  List<Object?> get props => [id, title];
}
