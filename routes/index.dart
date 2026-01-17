import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final request = context.read<String>();
  return Response(body: 'Welcome to Dart Frog ROOT route! $request');
}
