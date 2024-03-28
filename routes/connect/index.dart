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

Future<Response> _getConnect(RequestContext context) async {
  try {
    final dataSource = context.read<ComptesDataSource>();
    final email = context.request.uri.queryParameters['email'];
    final password = context.request.uri.queryParameters['password'];

    print("Handling GET request for authentication...");

    if (email != null && password != null) {
      print("Email: $email, Password: $password");

      try {
        print("Authenticating user...");
        bool isAuthenticated = await dataSource.authenticateUser(
          email.toString(),
          password.toString(),
        );

        // Récupérer la référence du document correspondant à l'email
        final docReference =
            await dataSource.getDocumentReferenceByEmail(email.toString());

        print("Authentication result: $isAuthenticated");

        // Return a JSON response indicating authentication result and document reference
        return Response.json(body: {
          'authenticated': isAuthenticated,
          'documentReference': docReference,
        });
      } catch (e) {
        // Handle authentication failure
        print("Authentication failed: $e");
        return Response(
          statusCode: HttpStatus.badRequest,
        );
      }
    }

    // Missing email or password in the query parameters
    print("Email or password missing in the query parameters.");
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  } catch (e) {
    // Handle unexpected errors during request processing
    print("Error processing request: $e");
    return Response(
      statusCode: HttpStatus.internalServerError,
    );
  }
}
