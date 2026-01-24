
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/models/list/list.dart';
import 'package:training_api/repositories/list/list_respository.dart';
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

Future<Response> _handleGet(RequestContext context) async {
  final id = context.request.uri.queryParameters['id'];

  if (id != null) {
    return _getListById(context, id);
  } else {
    return _getAllLists(context);
  }
}

Future<Response> _handlePost(RequestContext context) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final list = TaskList.fromJson(json);
    return _createList(context, list);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Invalid request body: $e',
    );
  }
}

Future<Response> _handlePut(RequestContext context) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final list = TaskList.fromJson(json);
    return _updateList(context, list);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Invalid request body: $e',
    );
  }
}

Future<Response> _handleDelete(RequestContext context) async {
  final id = context.request.uri.queryParameters['id'];

  if (id == null || id.isEmpty) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'ID parameter is required for DELETE',
    );
  }

  return _deleteList(context, id);
}

Future<Response> _getAllLists(RequestContext context) async {
  try {
    final redis = context.read<RedisService>();
    const cacheKey = 'lists:all';

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
    final lists = await ListRespository().getLists();

    // Convert to JSON-serializable format
    final listsJson = lists.map((list) => list.toJson()).toList();

    // Cache for 5 minutes
    if (redis.isConnected) {
      await redis.setJsonList(cacheKey, listsJson, expirySeconds: 300);
    }

    return Response.json(
      body: listsJson,
      headers: {'X-Cache': 'MISS'},
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching lists: $e',
    );
  }
}

Future<Response> _getListById(RequestContext context, String id) async {
  try {
    final redis = context.read<RedisService>();
    final cacheKey = 'list:$id';

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
    final list = await ListRespository().getListById(id);

    if (list == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'List with id $id not found',
      );
    }

    final listJson = list.toJson();

    // Cache for 5 minutes
    if (redis.isConnected) {
      await redis.setJson(cacheKey, listJson, expirySeconds: 300);
    }

    return Response.json(
      body: listJson,
      headers: {'X-Cache': 'MISS'},
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching list: $e',
    );
  }
}

Future<Response> _createList(RequestContext context, TaskList list) async {
  try {
    print('Creating list with id: ${list.id}, title: ${list.title}');

    final repository = ListRespository();
    final createdList = await repository.createList(list);

    // Invalidate cache after creating
    final redis = context.read<RedisService>();
    if (redis.isConnected) {
      await redis.delete(['lists:all']);
      print('Invalidated cache: lists:all');
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: createdList.toJson(),
    );
  } catch (e) {
    print('Error in _createList: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error creating list: $e',
    );
  }
}

Future<Response> _updateList(RequestContext context, TaskList list) async {
  try {
    final updatedList = await ListRespository().updateList(list);

    if (updatedList == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'List with id ${list.id} not found',
      );
    }

    // Invalidate cache after updating
    final redis = context.read<RedisService>();
    if (redis.isConnected) {
      await redis.delete(['list:${list.id}', 'lists:all']);
      print('Invalidated cache: list:${list.id}, lists:all');
    }

    return Response.json(
      body: updatedList.toJson(),
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error updating list: $e',
    );
  }
}

Future<Response> _deleteList(RequestContext context, String id) async {
  try {
    final deleted = await ListRespository().deleteList(id);

    if (!deleted) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'List with id $id not found',
      );
    }

    // Invalidate cache after deleting
    final redis = context.read<RedisService>();
    if (redis.isConnected) {
      await redis.delete(['list:$id', 'lists:all']);
      print('Invalidated cache: list:$id, lists:all');
    }

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error deleting list: $e',
    );
  }
}
