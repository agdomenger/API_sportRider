// routes/epreuves/index.dart
import 'dart:async';
import 'dart:io';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

Future<dynamic> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getEpreuve(context);
    case HttpMethod.post:
      return _postEpreuve(context);
    case HttpMethod.delete:
      return _deleteEpreuve(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<FutureOr<Response>> _postEpreuve(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    final Map<String, dynamic> requestBody =
        (await context.request.json()) as Map<String, dynamic>;
    print(requestBody);

    if (requestBody.containsKey('compteId')) {
      final dynamic compteIdDynamic = requestBody['compteId'];

      final dynamic chevalIdDynamic = requestBody['chevalId'];

      // Perform a runtime type check (cast) to ensure it's a String
      if (compteIdDynamic is String && chevalIdDynamic is String) {
        final String compteId = compteIdDynamic;
        final String chevalId = chevalIdDynamic;

        final List<String> epreuveIds =
            (requestBody['epreuveIds'] as List<dynamic>?)
                    ?.map((id) => id as String)
                    ?.toList() ??
                [];

        // You might want to validate the list of IDs here if needed

        return Response.json(
          statusCode: HttpStatus.created,
          body: await dataSource.addEpreuve(compteId, chevalId, epreuveIds),
        );
      } else {
        // Handle the case where 'compteId' is not a String
        return Response(
          statusCode: HttpStatus.badRequest,
        );
      }
    } else {
      final epreuveJson = requestBody;
      print(requestBody);
      final epreuve = Epreuve.fromJson(epreuveJson);

      return Response.json(
        statusCode: HttpStatus.created,
        body: await dataSource.createEpreuve(epreuve),
      );
    }
  } catch (e) {
    print(e);
    // Handle JSON parsing or other errors
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  }
}

Future<Response> _getEpreuve(RequestContext context) async {
  try {
    final dataSource = context.read<ComptesDataSource>();
    final Map<String, dynamic> requestBody =
        (await context.request.json()) as Map<String, dynamic>;
    final chevalId = requestBody['chevalId'];
    final compteId = requestBody['compteId'];
    // Ajoutez la logique pour récupérer la liste des épreuves
    final epreuves = await dataSource.readAllEpreuves(
        compteId.toString(), chevalId.toString());

    // Vous pouvez ajuster la réponse en fonction de vos besoins
    return Response.json(body: epreuves);
  } catch (e) {
    print('Error getting epreuves: $e');
    return Response(statusCode: HttpStatus.internalServerError);
  }
}

Future<Response> _deleteEpreuve(RequestContext context) async {
  final Map<String, dynamic> requestBody =
      (await context.request.json()) as Map<String, dynamic>;
  try {
    final chevalId = requestBody['chevalId'];
    final epreuveId = requestBody['epreuveId'];
    if (chevalId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
      );
    }

    final dataSource = context.read<ComptesDataSource>();
    await dataSource.deleteEpreuve(chevalId.toString(), epreuveId.toString());

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    print('Error: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
    );
  }
}


/*
Créer une épreuve : 
curl --request POST \  --url http://localhost:8080/epreuve \
  --header 'Content-Type: application/json' \
  --data '{
    "niveau": "un",
    "discipline": "cce",
    "categorie": "amat"
}'



ajouter une épreuve à un cheval lié à un compte : 
curl --request POST \  --url http://localhost:8080/epreuve \
  --header 'Content-Type: application/json' \
  --data '{
    "compteId": "ca5sXHX2HwwptOVpQ5P4",
    "chevalId": "428cdc0d-08e0-45e8-803d-45a31e739a7e",
    "epreuveIds": ["uQuMbOUkpAJkmG6y7F6r"]
}'

*/ 
