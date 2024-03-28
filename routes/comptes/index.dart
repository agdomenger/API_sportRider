import 'dart:async';
import 'dart:io';
import 'package:firedart/firedart.dart';
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
  final email = context.request.uri.queryParameters['email'];
  final password = context.request.uri.queryParameters['password'];

  if (email != null && password != null) {
    // Recherche du compte avec les informations fournies
    final existingCompte =
        await dataSource.findCompteByEmailAndPassword(email, password);

    if (existingCompte != null) {
      // Le compte existe
      // Vous pouvez ajuster la réponse en fonction de vos besoins
      return Response.json(body: {"message": "Compte existe"});
    } else {
      // Aucun compte trouvé avec les informations fournies
      // Vous pouvez ajuster la réponse en fonction de vos besoins
      return Response.json(body: {"message": "Compte non trouvé"});
    }
  } else {
    // Si aucun email et mot de passe n'est fourni, récupérez tous les comptes
    final comptes = await dataSource.readAll();
    // Vous pouvez ajuster la réponse en fonction de vos besoins
    return Response.json(body: comptes);
  }
}

Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<ComptesDataSource>();
  try {
    final compteJson = await context.request.json() as Map<String, dynamic>;
    final compte = Compte.fromJson(compteJson);

    // Hasher le mot de passe avant d'ajouter le compte
    compte.setPassword(compte.passwordHash);

    return Response.json(
      statusCode: HttpStatus.created,
      body: await dataSource.create(compte),
    );
  } catch (e) {
    // Gérer les erreurs de parsing JSON ou autres erreurs
    return Response(
      statusCode: HttpStatus.badRequest,
    );
  }
}


/*
exemples de requetes 

pour creer un compte : 
curl --request POST \
  --url http://localhost:8080/comptes \
  --header 'Content-Type: application/json' \
  --data '{
    "email": "nouveaucompte@example.com",
    "passwordHash": "MotDePasseSecurise"
  }'


pour recuperer tout les comptes : curl -X GET "http://localhost:8080/comptes"
*/
