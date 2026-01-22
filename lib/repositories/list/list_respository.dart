import 'package:training_api/models/list/list.dart';

/// List's repository
class ListRespository {
  /// Private constructor
  ListRespository._();

  /// Singleton instance
  static final ListRespository _instance = ListRespository._();

  /// Get the singleton instance
  factory ListRespository() => _instance;

  /// Shared database map (not final, remove final keyword)
  final Map<String, TaskList> _taskListsDb = {};

  /// Get all lists
  Future<List<TaskList>> getLists() async {
    try {
      // Return a copy of the list to prevent modification of the original data
      return List<TaskList>.from(_taskListsDb.values);
    } catch (e) {
      throw Exception('Failed to fetch lists: $e');
    }
  }

  /// Get list by id
  Future<TaskList?> getListById(String id) async {
    try {
      // Return null if not found instead of throwing with !
      return _taskListsDb[id];
    } catch (e) {
      throw Exception('Failed to fetch list with id $id: $e');
    }
  }

  /// Create list
  Future<TaskList> createList(TaskList list) async {
    try {
      // Validate the list
      if (list.id.isEmpty) {
        throw ArgumentError('List ID cannot be empty');
      }

      // Check if list already exists
      if (_taskListsDb.containsKey(list.id)) {
        throw Exception('List with id ${list.id} already exists');
      }

      // Store the list
      _taskListsDb[list.id] = list;
      return list;
    } catch (e) {
      throw Exception('Failed to create list: $e');
    }
  }

  /// Update list
  Future<TaskList?> updateList(TaskList list) async {
    try {
      // Validate the list
      if (list.id.isEmpty) {
        throw ArgumentError('List ID cannot be empty');
      }

      // Check if list exists
      if (!_taskListsDb.containsKey(list.id)) {
        return null; // Return null if not found
      }

      // Update the list
      _taskListsDb[list.id] = list;
      return list;
    } catch (e) {
      throw Exception('Failed to update list with id ${list.id}: $e');
    }
  }

  /// Delete list
  Future<bool> deleteList(String id) async {
    try {
      // Check if list exists
      if (!_taskListsDb.containsKey(id)) {
        return false;
      }

      // Remove the list
      _taskListsDb.remove(id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete list with id $id: $e');
    }
  }
}
