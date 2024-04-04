// routes/logout/index.dart
import 'dart:async';
import 'dart:io';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

Future<dynamic> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getLogout(context);
    case HttpMethod.post:
    case HttpMethod.delete:
      ;
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/*
deconnecter l'utilisateur
 */
Future<FutureOr<Response>> _getLogout(RequestContext context) async {
  try {
    final dataSource = context.read<ComptesDataSource>();

    // Appelez la méthode logoutUser qui gere la deconection du token firebase
    await dataSource.logoutUser();

    // deco réussie
    return Response(
      statusCode: HttpStatus.ok,
      body: 'Déconnexion réussie',
    );
  } catch (e) {
    // En cas d'erreur
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Une erreur s\'est produite lors de la déconnexion',
    );
  }
}
