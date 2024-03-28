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
  final Map<String, dynamic> requestBody =
      (await context.request.json()) as Map<String, dynamic>;
  final dynamic compteIdDynamic = requestBody['compteId'];
  final String compteId = compteIdDynamic.toString();

  final events = await dataSource.readAllEvenements(compteId);
  // Vous pouvez ajuster la réponse en fonction de vos besoins
  return Response.json(body: events);
}

Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    final Map<String, dynamic> requestBody =
        (await context.request.json()) as Map<String, dynamic>;
    print(requestBody);

// Vérification de la présence et de la non-nullité de 'compteId'
    if (requestBody.containsKey('compteId') &&
        requestBody['compteId'] is String) {
      final dynamic compteIdDynamic = requestBody['compteId'];

      // Vérification du type 'String' pour 'compteId'
      if (compteIdDynamic is String) {
        final String compteId = compteIdDynamic;
        print("okkkkkk");

        // Vérification de la présence de 'evenement' dans le corps de la requête
        if (requestBody.containsKey('evenement')) {
          final dynamic eventDynamic = requestBody['evenement'];
          print("okkkkkk");
          print("Event dynamic: $eventDynamic");

          // Vérification de la nullité de 'eventDynamic' et du type 'Map<String, dynamic>'
          if (eventDynamic != null && eventDynamic is Map<String, dynamic>) {
            // Conversion de 'eventDynamic' en objet Evenement
            print("on passe ici");
            final Evenement event = Evenement.fromJson(eventDynamic);
            print(event.toString());
            // Vérification de la réussite de la conversion
            if (event != null) {
              print("on passe ici 2");
              // Ajout de l'événement dans la source de données
              return Response.json(
                statusCode: HttpStatus.created,
                body: await dataSource.addEvenement(compteId, event),
              );
            } else {
              print('Invalid Evenement data');
              return Response(
                statusCode: HttpStatus.badRequest,
              );
            }
          } else {
            print('Invalid or null Evenement data');
            return Response(
              statusCode: HttpStatus.badRequest,
            );
          }
        } else {
          print('Missing Evenement in request');
          return Response(
            statusCode: HttpStatus.badRequest,
          );
        } // ... (le reste de la logique reste inchangé)
      } else {
        // Handle the case where 'compteId' is not a String
        print('Invalid Compte ID');
        return Response(
          statusCode: HttpStatus.badRequest,
        );
      }
    } else {
      print('Missing or null Compte ID');
      return Response(
        statusCode: HttpStatus.badRequest,
      );
    }
  } catch (e) {
    print('Error: $e');
    // Handle JSON parsing or other errors
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  }

  // Ajoutez une déclaration 'throw' pour signaler que la fonction peut générer une exception non capturée
  throw Exception('Unexpected error in _post function');
}
