import 'dart:async';
import 'dart:io';

import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/*
récuperer l'utilisateur connecté
 */
Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    final currentUser = await dataSource.getCurrentUser();

    if (currentUser != null) {
      // Récupérez l'email de l'utilisateur
      final email = currentUser.email;

      // Récupérez le document ID référence du document stocké dans Firebase
      final docReference =
          await dataSource.getDocumentReferenceByEmail(email as String?);
      final userJson = {
        'email': email,
        'documentReference': docReference,
      };

      // Retournez les informations de l'utilisateur au format JSON
      return Response.json(body: userJson);
    } else {
      return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'No user is currently signed in.');
    }
  } catch (e) {
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Error getting user information: $e');
  }
}
