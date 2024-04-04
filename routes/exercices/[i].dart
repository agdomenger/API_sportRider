import 'dart:async';
import 'dart:io';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart'; // Importez votre source de données pour les exercices

FutureOr<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final dataSource = context.read<ComptesDataSource>();

  final requestBody = await context.request.json();
  final idCmpt = requestBody['idCompte'] as String;
  final index = requestBody['index'] as int;

  final exercice = await dataSource.getExerciceById(id, index, idCmpt);

  if (exercice == null) {
    return Response(
        statusCode: HttpStatus.notFound, body: 'Exercice not found');
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, exercice);
    case HttpMethod.put:
      return _put(context, id, index, idCmpt);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/*
non utilisé, a modifier pour plus tard 
 */
Future<Response> _get(RequestContext context, dynamic exercice) async {
  try {
    return Response.json(body: exercice);
  } catch (e) {
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Error getting exercice information: $e');
  }
}

/*
idem, n'est pas utilisé pour l'instant
 */
Future<Response> _put(
    RequestContext context, String id, int index, String idCmpt) async {
  try {
    final dataSource = context.read<ComptesDataSource>();

    // Vérifiez si les données requises sont présentes dans le corps de la requête
    if (idCmpt == null || index == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Missing required parameters in request body',
      );
    }
    // Mettre à jour l'exercice avec les données fournies
    final newExercice =
        await dataSource.updateExercice(id, index, idCmpt, true);

    // Retournez la réponse avec le nouvel exercice mis à jour
    return Response.json(body: "ok");
  } catch (e) {
    // Gérez les erreurs
    print('Error updating exercise: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error updating exercise: $e',
    );
  }
}
