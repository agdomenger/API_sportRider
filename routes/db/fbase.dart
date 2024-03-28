import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:firedart/firestore/firestore.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => _getComptes(context),
    HttpMethod.post => _createComptes(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getComptes(RequestContext context) async {
  final lists = <Map<String, dynamic>>[];
  await Firestore.instance.collection('tasklists').get().then((event) {
    for (final doc in event) {
      lists.add(doc.map);
    }
  });
  return Response.json(body: lists.toString());
}

Future<Response> _createComptes(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;

  final list = <String, dynamic>{'name': name};
  final id =
      await Firestore.instance.collection('tasklists').add(list).then((doc) {
    return doc.id;
  });

  return Response.json(body: {'id': id});
}
