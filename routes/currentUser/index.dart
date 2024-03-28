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

Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    // Obtenez l'utilisateur actuellement connecté
    final currentUser = await dataSource
        .getCurrentUser(); // Utilisez votre méthode pour obtenir l'utilisateur connecté

    if (currentUser != null) {
      // Récupérez l'email de l'utilisateur
      final email = currentUser
          .email; // Utilisez la méthode appropriée pour récupérer l'email de l'utilisateur

      // Récupérez le document ID référence du document stocké dans Firebase
      final docReference = await dataSource.getDocumentReferenceByEmail(email
          as String?); // Utilisez votre méthode pour récupérer le document ID

      // Créez un objet JSON contenant toutes les informations de l'utilisateur ainsi que le document ID référence
      final userJson = {
        'email': email,
        // Par exemple, récupérez l'UID de l'utilisateur
        // Ajoutez d'autres informations de l'utilisateur ici si nécessaire
        'documentReference': docReference, // Ajoutez le document ID référence
      };

      // Retournez les informations de l'utilisateur sous forme de réponse JSON
      return Response.json(body: userJson);
    } else {
      // Si aucun utilisateur n'est connecté, retournez un message approprié
      return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'No user is currently signed in.');
    }
  } catch (e) {
    // Si une erreur se produit lors de la récupération de l'utilisateur, retournez un message d'erreur
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Error getting user information: $e');
  }
}
