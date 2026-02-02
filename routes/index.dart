import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.get => _getRoot(context),
    HttpMethod.post => _addRequest(context),
    _ => Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method not allowed',
      ),
  };
}

Response _getRoot(RequestContext context) {
  return Response.json(
    body: [
      {'id': 1, 'name': 'first name'},
      {'id': 2, 'name': 'second name'},
    ],
  );
}

Response _addRequest(RequestContext context) {
  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'id': 3,
      'name': 'third name',
    },
  );
}
