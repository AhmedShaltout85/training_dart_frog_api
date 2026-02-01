import 'package:dart_frog/dart_frog.dart';

Future< Response> onRequest(RequestContext context) async{
  final request = context.read<String>();
  return Response(body: 'Welcome to Dart Frog ROOT route! $request');
}
