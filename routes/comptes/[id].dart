import 'dart:async';
import 'dart:io';

import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  final dataSource = context.read<ComptesDataSource>();
  final compte = await dataSource.read(id);

  if (compte == null) {
    return Response(statusCode: HttpStatus.notFound, body: 'Not found');
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.put:
      return _put(context, id, compte);
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/*
fonction permetant la récupération des informations relative à l'ID fournit 
 */
Future<Response> _get(RequestContext context, String id) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    // Obtenez les informations de l'utilisateur par son ID de document reference dans firebase
    final userInfo = await dataSource.getUserInfoById(id);

    if (userInfo != null) {
      // Retournez les informations de l'utilisateur au format JSON
      return Response.json(body: userInfo);
    } else {
      // Si aucun utilisateur n'est trouvé
      return Response(statusCode: HttpStatus.notFound, body: 'User not found.');
    }
  } catch (e) {
    // Si une erreur se produit lors de la récupération des informations de l'utilisateur

    return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Error getting user information: $e');
  }
}

/*
Fonction pour modifier un compte utilisateur 
pas utilisé dans le code à ce jour mais potentiellement utile 
 */
Future<Response> _put(RequestContext context, String id, Compte compte) async {
  final dataSource = context.read<ComptesDataSource>();
  final updatedCompte = Compte.fromJson(
    await context.request.json() as Map<String, dynamic>,
  );
  final newCompte = await dataSource.update(
    id,
    compte.copyWith(
      email: updatedCompte.email,
      passwordHash: updatedCompte.email,
    ),
  );

  return Response.json(body: newCompte);
}

/*
fonction permettant de supprimer un compte */
Future<Response> _delete(RequestContext context, String id) async {
  final dataSource = context.read<ComptesDataSource>();
  await dataSource.delete(id);
  return Response(statusCode: HttpStatus.noContent);
}
