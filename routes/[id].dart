import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return switch (context.request.method) {
    HttpMethod.delete => _deleteRequest(context),
    HttpMethod.put => _putRequest(context, int.parse(id)),
    _ => Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method not allowed',
      ),
  };
}

Response _deleteRequest(RequestContext context) {
  return Response.json(
    statusCode: HttpStatus.noContent,
    body: {},
  );
}

Response _putRequest(RequestContext context, int id) {
  return Response.json(
    body: {
      'id': id,
      'name': 'third name',
    },
  );
}
