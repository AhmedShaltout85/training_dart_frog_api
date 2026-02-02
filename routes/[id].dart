// ignore_for_file: no_default_cases

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

// Response onRequest(RequestContext context, String id) {
//   return switch (context.request.method) {
//     HttpMethod.delete => _deleteRequest(context),
//     HttpMethod.put => _putRequest(context, int.parse(id)),
//     _ => Response(
//         statusCode: HttpStatus.methodNotAllowed,
//         body: 'Method not allowed',
//       ),
//   };
// }

Response onRequst(RequestContext context, String id) {
  switch (context.request.method) {
    case HttpMethod.delete:
      return _deleteRequest(context);
    case HttpMethod.put:
      return _putRequest(context, int.parse(id));
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method not allowed',
      );
  }
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
