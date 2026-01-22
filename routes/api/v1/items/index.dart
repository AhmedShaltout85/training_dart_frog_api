import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/models/items/item.dart';
import 'package:training_api/repositories/item/item_repository.dart';

Future<Response> onRequest(RequestContext context) async{
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
      return _handleGetById(id);
    } else {
      // Get all items
      return _handleGetAll();
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
    return Response.json(
      statusCode: HttpStatus.created,
      body: createdItem.toJson(), // Make sure to convert to JSON
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

    return Response.json(
      body: updatedItem.toJson(), // Make sure to convert to JSON
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

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error deleting item: $e',
    );
  }
}

/// Get an item by id
Future<Response> _handleGetById(String id) async {
  try {
    final item = await ItemRepository().getItemById(id);

    if (item == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Item with id $id not found',
      );
    }

    return Response.json(
      body: item.toJson(), // Make sure to convert to JSON
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching item: $e',
    );
  }
}

/// Get all items
Future<Response> _handleGetAll() async {
  try {
    final items = await ItemRepository().getItems();

    // Convert each item to JSON
    final itemsJson = items.map((item) => item.toJson()).toList();

    return Response.json(body: itemsJson);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching items: $e',
    );
  }
}
