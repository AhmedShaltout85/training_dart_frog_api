import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:training_api/models/list/list.dart';
import 'package:training_api/repositories/list/list_respository.dart';

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
    return _getListById(id);
  } else {
    return _getAllLists();
  }
}

Future<Response> _handlePost(RequestContext context) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final list = TaskList.fromJson(json);
    return _createList(list);
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
    return _updateList(list);
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

  return _deleteList(id);
}

Future<Response> _getAllLists() async {
  try {
    final lists = await ListRespository().getLists();
    return Response.json(
      body: lists,
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching lists: $e',
    );
  }
}

Future<Response> _getListById(String id) async {
  try {
    final list = await ListRespository().getListById(id);
    if (list == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'List with id $id not found',
      );
    }
    return Response.json(
      body: list,
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error fetching list: $e',
    );
  }
}

// Future<Response> _createList(TaskList list) async {
//   try {
//     final createdList = await ListRespository().createList(list);
//     return Response.json(
//       statusCode: HttpStatus.created,
//       body: createdList,
//     );
//   } catch (e) {
//     return Response(
//       statusCode: HttpStatus.internalServerError,
//       body: 'Error creating list: $e',
//     );
//   }
// }
Future<Response> _createList(TaskList list) async {
  try {
    print('Creating list with id: ${list.id}, title: ${list.title}');

    final repository = ListRespository();
    print('Repository hashcode: ${repository.hashCode}');

    final createdList = await repository.createList(list);

    // Check if it's actually stored
    final allLists = await repository.getLists();
    print('After creation, database has ${allLists.length} lists');

    return Response.json(
      statusCode: HttpStatus.created,
      body: createdList.toJson(), // Make sure to call toJson()
    );
  } catch (e) {
    print('Error in _createList: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error creating list: $e',
    );
  }
}

Future<Response> _updateList(TaskList list) async {
  try {
    final updatedList = await ListRespository().updateList(list);
    if (updatedList == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'List with id ${list.id} not found',
      );
    }
    return Response.json(
      body: updatedList,
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error updating list: $e',
    );
  }
}

Future<Response> _deleteList(String id) async {
  try {
    final deleted = await ListRespository().deleteList(id);
    if (!deleted) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'List with id $id not found',
      );
    }
    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error deleting list: $e',
    );
  }
}
