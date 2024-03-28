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
    case HttpMethod.put:
      return _put(context);
    case HttpMethod.delete:
      return _delete(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final Map<String, dynamic> requestBody =
      (await context.request.json()) as Map<String, dynamic>;
  try {
    final dynamic compteIdDynamic = requestBody['compteId'];

    if (compteIdDynamic == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
      );
    }

    final dataSource = context.read<ComptesDataSource>();
    final equides = await dataSource.readAllEquides(compteIdDynamic.toString());

    return Response.json(body: equides);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _post(RequestContext context) async {
  try {
    final Map<String, dynamic> requestBody =
        (await context.request.json()) as Map<String, dynamic>;

    if (requestBody.containsKey('cmptId')) {
      final dynamic compteIdDynamic = requestBody['cmptId'];

      // Perform a runtime type check (cast) to ensure it's a String
      if (compteIdDynamic is String) {
        final String compteId = compteIdDynamic;

        final dynamic equidesJsonDynamic = requestBody['equides'];
        if (equidesJsonDynamic == null || equidesJsonDynamic is! List) {
          print("ptn oui c'est là");
          return Response(
            statusCode: HttpStatus.badRequest,
          );
        }

        final List<dynamic> equidesJsonList = equidesJsonDynamic;
        final List<Map<String, dynamic>> equidesJson =
            equidesJsonList.cast<Map<String, dynamic>>();

        final dataSource = context.read<ComptesDataSource>();
        final equides = equidesJson
            .map((e) => Equide.fromJson(e as Map<String, dynamic>))
            .toList();

        final updatedEquides =
            await dataSource.addNewListeEquide(compteId, equides);

        return Response.json(body: updatedEquides);
      } else {
        // Handle the case where 'compteId' is not a String
        return Response(
          statusCode: HttpStatus.badRequest,
        );
      }
    } else {
      // Handle the case where 'compteId' is not present in the request body
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
}

Future<Response> _put(RequestContext context) async {
  final Map<String, dynamic> requestBody =
      (await context.request.json()) as Map<String, dynamic>;
  try {
    final cmptId = requestBody['compteId'];
    final equideId = requestBody['equideId'];
    if (cmptId == null || equideId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
      );
    }

    final dataSource = context.read<ComptesDataSource>();
    await dataSource.removeOneEquide(cmptId as String, equideId as String);

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _delete(RequestContext context) async {
  final Map<String, dynamic> requestBody =
      (await context.request.json()) as Map<String, dynamic>;
  try {
    final cmptId = requestBody['compteId'];
    if (cmptId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
      );
    }

    final dataSource = context.read<ComptesDataSource>();
    await dataSource.removeAllEquides(cmptId as String);

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    print('Error: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
    );
  }
}