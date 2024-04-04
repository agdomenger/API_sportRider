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
recuperer tous les evenements d'un compte 
l'id du compte est necessaire
 */
Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  final Map<String, dynamic> requestBody =
      (await context.request.json()) as Map<String, dynamic>;
  final dynamic compteIdDynamic = requestBody['compteId'];
  final String compteId = compteIdDynamic.toString();

  final events = await dataSource.readAllEvenements(compteId);
  return Response.json(body: events);
}

/*
créer un evenement et le lier à un compte 
l'id du compte est necessaire 
 */
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

      if (compteIdDynamic is String) {
        final String compteId = compteIdDynamic;

        // Vérification de la présence de 'evenement' dans le corps de la requête
        if (requestBody.containsKey('evenement')) {
          final dynamic eventDynamic = requestBody['evenement'];

          if (eventDynamic != null && eventDynamic is Map<String, dynamic>) {
            final Evenement event = Evenement.fromJson(eventDynamic);
            if (event != null) {
              print("on passe ici 2");
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
        }
      } else {
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

    return Response(
      statusCode: HttpStatus.badRequest,
    );
  }

  throw Exception('Unexpected error in _post function');
}
