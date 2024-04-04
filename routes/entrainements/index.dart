import 'dart:async';
import 'dart:io';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/*
route permettant de retourner tout les entrainements créés */
Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  final exercices = await dataSource.readAllEntrainements();
  return Response.json(body: exercices);
}

/*
requête permettant de créer un entrainement pour un compte fournit*/
Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    final Map<String, dynamic> requestBody =
        (await context.request.json()) as Map<String, dynamic>;

    if (requestBody.containsKey('compteId')) {
      final dynamic compteIdDynamic = requestBody['compteId'];

      if (compteIdDynamic is String) {
        final String compteId = compteIdDynamic;
        final List<String> exerciceIds =
            (requestBody['exerciceIds'] as List<dynamic>?)
                    ?.map((id) => id as String)
                    ?.toList() ??
                [];
        return Response.json(
          statusCode: HttpStatus.created,
          body: await dataSource.createEntrainement(compteId, exerciceIds),
        );
      } else {
        return Response(
          statusCode: HttpStatus.badRequest,
        );
      }
    } else {
      final exoJson = requestBody;
      final exo = Exercice.fromJson(exoJson);

      return Response.json(
        statusCode: HttpStatus.created,
        body: await dataSource.createExercice(exo),
      );
    }
  } catch (e) {
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  }
}


/*
 requêtes sur les entrainements :


curl --request POST \
  --url http://localhost:8080/entrainements \
  --header 'Content-Type: application/json' \
  --data '{
    "compteId": "c8bc53ed-de7c-4021-86f6-39f441ccb110",
    "exerciceIds": ["54d22279-0add-4b93-9105-d26d1fc5d502"]
  }'


*/ 