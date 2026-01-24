
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/models/items/item.dart';
import 'package:training_api/repositories/item/item_repository.dart';
import 'package:training_api/services/redis_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGet(context);
    case HttpMethod.post:
      return _handlePost(context);
    case HttpMethod.put:
      return _handlePut(context);
    case HttpMethod.delete:
      return _handleDelete(context);
    // ignore: no_default_cases
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method not allowed',
      );
  }
}

/// Handle GET requests
Future<Response> _handleGet(RequestContext context) async {
  try {
    final id = context.request.uri.queryParameters['id'];

    if (id != null) {
      // Get item by ID
      return _handleGetById(context, id);
    } else {
      // Get all items
      return _handleGetAll(context);
    }
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error handling GET request: $e',
    );
  }
}

/// Create an item
Future<Response> _handlePost(RequestContext context) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final item = Item.fromJson(json);
    final createdItem = await ItemRepository().createItem(item);

    // Invalidate cache after creating
    final redis = context.read<RedisService>();
    if (redis.isConnected) {
      await redis.delete(['items:all']);
      print('Invalidated cache: items:all');
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: createdItem.toJson(),
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Invalid request body: $e',
    );
  }
}

/// Update an item
Future<Response> _handlePut(RequestContext context) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final item = Item.fromJson(json);
    final updatedItem = await ItemRepository().updateItem(item);

    if (updatedItem == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Item with id ${item.id} not found',
      );
    }

    // Invalidate cache after updating
    final redis = context.read<RedisService>();
    if (redis.isConnected) {
      await redis.delete(['item:${item.id}', 'items:all']);
      print('Invalidated cache: item:${item.id}, items:all');
    }

    return Response.json(
      body: updatedItem.toJson(),
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Invalid request body: $e',
    );
  }
}

/// Delete an item
Future<Response> _handleDelete(RequestContext context) async {
  try {
    final id = context.request.uri.queryParameters['id'];

    if (id == null || id.isEmpty) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'ID parameter is required for DELETE',
      );
    }

    final deleted = await ItemRepository().deleteItem(id);

    if (!deleted) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Item with id $id not found',
      );
    }

    // Invalidate cache after deleting
    final redis = context.read<RedisService>();
    if (redis.isConnected) {
      await redis.delete(['item:$id', 'items:all']);
      print('Invalidated cache: item:$id, items:all');
    }

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error deleting item: $e',
    );
  }
}

/// Get an item by id
Future<Response> _handleGetById(RequestContext context, String id) async {
  try {
    final redis = context.read<RedisService>();
    final cacheKey = 'item:$id';

    // Try to get from cache
    if (redis.isConnected) {
      final cached = await redis.getJson(cacheKey);
      if (cached != null) {
        print('Cache hit for $cacheKey');
        return Response.json(
          body: cached,
          headers: {'X-Cache': 'HIT'},
        );
      }
    }

    // Cache miss - fetch from database
    print('Cache miss for $cacheKey - fetching from DB');
    final item = await ItemRepository().getItemById(id);

    if (item == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Item with id $id not found',
      );
    }

    final itemJson = item.toJson();

    // Cache for 5 minutes
    if (redis.isConnected) {
      await redis.setJson(cacheKey, itemJson, expirySeconds: 300);
    }

    return Response.json(
      body: itemJson,
      headers: {'X-Cache': 'MISS'},
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching item: $e',
    );
  }
}

/// Get all items
Future<Response> _handleGetAll(RequestContext context) async {
  try {
    final redis = context.read<RedisService>();
    const cacheKey = 'items:all';

    // Try to get from cache
    if (redis.isConnected) {
      final cached = await redis.getJsonList(cacheKey);
      if (cached != null) {
        print('Cache hit for $cacheKey');
        return Response.json(
          body: cached,
          headers: {'X-Cache': 'HIT'},
        );
      }
    }

    // Cache miss - fetch from database
    print('Cache miss for $cacheKey - fetching from DB');
    final items = await ItemRepository().getItems();

    // Convert each item to JSON
    final itemsJson = items.map((item) => item.toJson()).toList();

    // Cache for 5 minutes
    if (redis.isConnected) {
      await redis.setJsonList(cacheKey, itemsJson, expirySeconds: 300);
    }

    return Response.json(
      body: itemsJson,
      headers: {'X-Cache': 'MISS'},
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching items: $e',
    );
  }
}
