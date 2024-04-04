// routes/connect/index.dart
import 'dart:async';
import 'dart:io';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Object> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getConnect(context);
    case HttpMethod.options:
      // Indiquez les méthodes HTTP prises en charge par votre serveur
      final headers = {
        'allow': 'GET, OPTIONS',
        'access-control-allow-methods':
            'GET, OPTIONS', // Ajoutez les méthodes HTTP que votre serveur prend en charge
        'access-control-allow-headers':
            'Content-Type', // Ajoutez les en-têtes que votre serveur accepte
      };
      return Response(
        statusCode: HttpStatus.ok,
        body: '', // Le corps de la réponse OPTIONS doit être vide
        headers: headers,
      );
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/*
Permet de gerer la connection à l'app et de savoir si le compte existe
fait appel à la fonction get de compte  */
Future<Response> _getConnect(RequestContext context) async {
  try {
    final dataSource = context.read<ComptesDataSource>();
    final email = context.request.uri.queryParameters['email'];
    final password = context.request.uri.queryParameters['password'];

    if (email != null && password != null) {
      print("Email: $email, Password: $password");

      try {
        print("Authentification...");
        bool isAuthenticated = await dataSource.authenticateUser(
          email.toString(),
          password.toString(),
        );

        // Récupérer l'id de référence du document correspondant à l'email
        final docReference =
            await dataSource.getDocumentReferenceByEmail(email.toString());

        print("Authentication result: $isAuthenticated");

        return Response.json(body: {
          'authenticated': isAuthenticated,
          'documentReference': docReference,
        });
      } catch (e) {
        print("Authentication failed: $e");
        return Response(
          statusCode: HttpStatus.badRequest,
        );
      }
    }

    // si pas les parametres
    print("Email et/ou mot de passe non fournit");
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  } catch (e) {
    print("Error processing request: $e");
    return Response(
      statusCode: HttpStatus.internalServerError,
    );
  }
}
