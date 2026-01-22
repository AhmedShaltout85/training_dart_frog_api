import 'package:training_api/models/items/item.dart';

/// Item's repository
class ItemRepository {
  /// Private constructor
  ItemRepository._();

  /// Singleton instance - make this static and final
  static final ItemRepository _instance = ItemRepository._();

  /// Get the singleton instance
  factory ItemRepository() => _instance;

  /// Shared database map
  final Map<String, Item> _taskItemsDb = {};

  /// Get all items
  Future<List<Item>> getItems() async {
    try {
      // Return a copy of the list to prevent modification of the original data
      return List<Item>.from(_taskItemsDb.values);
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  /// Get item by id
  Future<Item?> getItemById(String id) async {
    try {
      // Return null if not found instead of throwing with !
      return _taskItemsDb[id];
    } catch (e) {
      throw Exception('Failed to fetch item with id $id: $e');
    }
  }

  /// Create item
  Future<Item> createItem(Item item) async {
    try {
      // Validate the item
      if (item.id.isEmpty) {
        throw ArgumentError('Item ID cannot be empty');
      }

      // Check if item already exists
      if (_taskItemsDb.containsKey(item.id)) {
        throw Exception('Item with id ${item.id} already exists');
      }

      // Store the item
      _taskItemsDb[item.id] = item;

      // Debug print
      print('Item created: ${item.id}, ${item.name}');
      print('Total items in DB: ${_taskItemsDb.length}');

      return item;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  /// Update item
  Future<Item?> updateItem(Item item) async {
    try {
      // Validate the item
      if (item.id.isEmpty) {
        throw ArgumentError('Item ID cannot be empty');
      }

      // Check if item exists
      if (!_taskItemsDb.containsKey(item.id)) {
        return null; // Return null if not found
      }

      // Update the item
      _taskItemsDb[item.id] = item;
      return item;
    } catch (e) {
      throw Exception('Failed to update item with id ${item.id}: $e');
    }
  }

  /// Delete item
  Future<bool> deleteItem(String id) async {
    try {
      // Check if item exists
      if (!_taskItemsDb.containsKey(id)) {
        return false;
      }

      // Remove the item
      _taskItemsDb.remove(id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete item with id $id: $e');
    }
  }

  /// Delete all items
  Future<void> deleteAllItems() async {
    try {
      // Remove all items
      _taskItemsDb.clear();
    } catch (e) {
      throw Exception('Failed to delete all items: $e');
    }
  }

  /// Debug method to print current state
  void debugPrint() {
    print('=== ItemRepository Debug ===');
    print('Items in DB: ${_taskItemsDb.length}');
    _taskItemsDb.forEach((key, value) {
      print('  $key: ${value.name}');
    });
    print('============================');
  }
}
