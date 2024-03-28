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

Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();

  final exercices = await dataSource.readAllExercice();
  // Vous pouvez ajuster la réponse en fonction de vos besoins
  return Response.json(body: exercices);
}

Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    final exoJson = await context.request.json() as Map<String, dynamic>;
    print("1");
    final exo = Exercice.fromJson(exoJson);
    print("2");
    return Response.json(
      statusCode: HttpStatus.created,
      body: await dataSource.createExercice(exo),
    );
  } catch (e) {
    // Gérer les erreurs de parsing JSON ou autres erreurs
    print('Error during parsing JSON: $e');
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  }
}


/*
 requêtes sur les exercices :

 récuperer les exercices d'une catégorie -- curl --request GET \
  --url 'http://localhost:8080/exercices?categorie=deb_moins16'


récuperer tout les exercices -- curl --request GET \
  --url http://localhost:8080/exercices


  créer un exo --- curl --request POST \
  --url http://localhost:8080/exercices \
  --header 'Content-Type: application/json' \
  --data '{
    "description": "Your exercice description",
    "categorie": "deb_moins16",
    "image": null
  }'




*/ 