import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final queryParams = {
    'id': 1,
    'name': 'an item',
  };
  // TODO: implement route handler
  return Response.json(
    body: queryParams,
  );
}
