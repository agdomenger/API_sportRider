import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:comptes_data_source/src/models/evenement.dart';
import 'package:firedart/firedart.dart';

import 'package:uuid/uuid.dart';

/// An in-memory implementation of the [ComptesDataSource] interface.
class InMemoryComptesDataSource implements ComptesDataSource {
  /// Map of ID -> Comptes
  ///
  final Firestore _firestore = Firestore.instance;

  Future<dynamic> getCurrentUser() async {
    try {
      var currentUser = await FirebaseAuth.instance.getUser();
      return currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<Compte> create(Compte cmpt) async {
    try {
      final id = const Uuid().v4();
      final createdCmpt = cmpt.copyWith(id: id);

      // Add the account directly to Firebase
      await _firestore.collection('comptes').add({
        'prenom': createdCmpt.prenom,
        'nom': createdCmpt.nom,
        'email': createdCmpt.email,
        'passwordHash': createdCmpt.passwordHash,
        'entrainements': [],
        'evenements': [],
        'equides': [],
        // Add other fields as needed
      });

      return createdCmpt;
    } catch (e) {
      // Handle errors
      print('Error creating account: $e');
      throw e;
    }
  }

  Future<List<Compte>> readAll() async {
    try {
      final List<Compte> comptes = [];

      await _firestore.collection('comptes').get().then((event) {
        for (final doc in event) {
          comptes.add(Compte.fromJson(doc.map));
        }
      });
      return comptes;
    } catch (e) {
      print('Error reading all accounts: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserInfoById(String userId) async {
    try {
      final snapshot =
          await _firestore.collection('comptes').document(userId).get();

      if (snapshot != null) {
        return snapshot.map;
      } else {
        print('User not found with ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error getting user information: $e');
      throw e;
    }
  }

  @override
  Future<Compte?> read(String id) async {
    try {
      // Instantiate a reference to a specific document in the 'comptes' collection

      DocumentReference documentRef =
          Firestore.instance.collection("comptes").document(id);

      var document = await documentRef.get();
      // Check if the document exists
      if (document != null) {
        var dataa = document.map;
        final Compte compte = Compte.fromJson(dataa);
        return compte;
      } else {
        // Document does not exist
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error reading account with id $id: $e');
      throw e;
    }
  }

  @override
  Future<void> delete(String id) async {
    await Firestore.instance
        .collection("comptes")
        .document(id)
        .delete()
        .then((value) {
      print("statusCode : HttpStatus.noContent");
    });
  }

  @override
  Future<Compte?> findCompteByEmailAndPassword(
      String email, String password) async {
    try {
      // Query the 'comptes' collection for the account with the given email
      var querySnapshot = await Firestore.instance
          .collection('comptes')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Check if any documents were found
      if (querySnapshot != null) {
        // Get the first document
        var document = await querySnapshot.map;
        final Compte compte = Compte.fromJson(document as Map<String, dynamic>);
        // Check if the password matches using the checkPassword method
        if (compte.checkPassword(password)) {
          return compte;
        }
      }

      // Account not found or password doesn't match
      return null;
    } catch (e) {
      print('Error finding account by email and password: $e');
      throw e;
    }
  }

  @override
  Future<List<Entrainement>?> createEntrainement(
      String compteId, List<String> exerciceIds) async {
    try {
      // Get a reference to the specific document in the 'comptes' collection
      print('Compte ID: $compteId');
      var documentRef =
          Firestore.instance.collection('comptes').document(compteId);

      // Get the current data of the document
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};
      print('Document Data: $data');

      // Extract the 'entrainements' field from the data, or return an empty list if it doesn't exist
      List<Map<String, dynamic>> entrainementsData = [];

      if (data['entrainements'] is List<dynamic>) {
        entrainementsData = (data['entrainements'] as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
      print('1');

      // Fetch the exercices from Firebase based on the provided exerciceIds
      List<Exercice> selectedExercices = [];

      for (String exerciceId in exerciceIds) {
        var exerciceSnapshot = await Firestore.instance
            .collection('exercices')
            .document(exerciceId)
            .get();
        Map<String, dynamic> exerciceData = exerciceSnapshot.map ?? {};
        selectedExercices.add(Exercice.fromJson(exerciceData));
      }
      print('2');

      print(selectedExercices.toString());

      // If the selectedExercices is not empty, create and add an Entrainement
      if (selectedExercices.isNotEmpty) {
        // Create a new Entrainement object
        final entrainement = Entrainement(
          compteId: compteId,
          exerciceIds: selectedExercices,
        );
        print('3');
        // Combine the existing list with the new entrainement
        List<Map<String, dynamic>> updatedEntrainements = [
          ...entrainementsData,
          entrainement.toJson(),
        ];
        print('4');

        // Update the document in Firebase with the new entrainements
        await documentRef.update({'entrainements': updatedEntrainements});
        print('5');
        return updatedEntrainements
            .map((json) => Entrainement.fromJson(json))
            .toList();
      } else {
        // No valid exercices found for the given ids
        return Future.error('No valid exercices found for the given ids');
      }
    } catch (e) {
      // Handle errors
      print('Error creating entrainement for compte with id $compteId: $e');
      throw e;
    }
  }

  @override
  Future<Exercice> createExercice(Exercice exercice) async {
    try {
      final id = const Uuid().v4();
      final createdExercice = exercice.copyWith(id: id);
      print(createdExercice.toString());
      // Add the exercice directly to Firebase
      await Firestore.instance.collection('exercices').add({
        'id': id,
        'status': false,
        'description': createdExercice.description,
        'categorie': createdExercice.categorie.toString().split('.').last,
        'image': createdExercice.url
        // Add other fields as needed
      });

      return createdExercice;
    } catch (e) {
      print('Error creating exercice: $e');
      throw e;
    }
  }

  @override
  Future<Epreuve> createEpreuve(Epreuve epreuve) async {
    try {
      final id = const Uuid().v4();
      final createdEpreuve = epreuve.copyWith(id: id);

      // Add the exercice directly to Firebase
      await Firestore.instance.collection('epreuves').add({
        'id': id,
        'categorie': createdEpreuve.categorie.toString().split('.').last,
        'discipline': createdEpreuve.discipline.toString().split('.').last,
        'niveau': createdEpreuve.niveau.toString().split('.').last,
        // Add other fields as needed
      });

      return createdEpreuve;
    } catch (e) {
      // Handle errors
      print('Error creating epreuve: $e');
      throw e;
    }
  }

  Future<List<String>> readAllExercice() async {
    try {
      final List<String> exerciceIds = [];

      // Obtenez la référence de la collection 'exercices'
      final CollectionReference exercicesRef =
          Firestore.instance.collection('exercices');

      // Obtenez tous les documents de la collection 'exercices'
      final Page<Document> page = await exercicesRef.get();

      // Convertissez la page en liste de documents et récupérez les IDs de chaque document
      final List<Document> documents = await page.toList();
      for (final Document document in documents) {
        exerciceIds.add(document.id);
      }

      return exerciceIds;
    } catch (e) {
      print('Error reading all exercice IDs: $e');
      throw e;
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> readAllEntrainements() async {
    try {
      final List<Map<String, dynamic>> entrainementsDetails = [];
      // Assuming 'comptes' is the collection containing the entrainements
      var querySnapshot =
          await Firestore.instance.collection('comptes').get().then((event) {
        for (final doc in event) {
          final Map<String, dynamic> compteData = doc.map ?? {};
          final List<Map<String, dynamic>> entrainementsList =
              (compteData['entrainements'] as List<dynamic>?)
                      ?.map((entrainement) => {
                            'compteId': compteData['id'],
                            'exerciceIds':
                                (entrainement['exerciceIds'] as List<dynamic>)
                                    .map((exerciceId) => exerciceId)
                                    .toList(),
                          })
                      .toList() ??
                  [];
          entrainementsDetails.addAll(entrainementsList);
        }
      });
      return entrainementsDetails;
    } catch (e) {
      // Handle any errors
      print('Error retrieving entrainements details: $e');
      throw e;
    }
  }

  @override
  Future<List<Entrainement>?> readAllEntrainementsCompte(
      String compteId) async {
    try {
      // Instantiate a reference to a specific document in the 'comptes' collection
      var documentRef = _firestore.collection('comptes').document(compteId);

      // Get the document snapshot
      var documentSnapshot = await documentRef.get();

      // Check if the document exists
      if (documentSnapshot != null) {
        // Extract the 'entrainements' field from the document data
        List<dynamic>? entrainementsData =
            documentSnapshot.map?['entrainements'] as List<dynamic>?;
        if (entrainementsData != null) {
          // Convert the raw data into a List<Entrainement>
          List<Entrainement> entrainements = entrainementsData
              .map((entrainement) =>
                  Entrainement.fromJson(entrainement as Map<String, dynamic>))
              .toList();

          return entrainements;
        } else {
          // No 'entrainements' field found in the document
          return [];
        }
      } else {
        // Document does not exist
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error reading entrainements for compte with id $compteId: $e');
      throw e;
    }
  }

  @override
  Future<List<Equide>?> readAllEquides(String cmptId) async {
    try {
      // Get a reference to the specific document in the 'comptes' collection
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);
      // Get the current data of the document
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};

      // Extract the 'equides' field from the data, or return null if it doesn't exist
      List<Map<String, dynamic>>? equidesData =
          data['equides'] as List<Map<String, dynamic>>?;

      // If 'equides' field exists, convert it to a list of Equide objects
      if (equidesData != null) {
        List<Equide> equides = equidesData
            .map((equideData) => Equide.fromJson(equideData))
            .toList();
        return equides;
      } else {
        return null;
      }
    } catch (e) {
      // Handle errors
      print('Error reading equides for compte with id $cmptId: $e');
      throw e;
    }
  }

  @override
  Future<void> removeAllEquides(String cmptId) async {
    try {
      // Get a reference to the specific document in the 'comptes' collection
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);
      // Update the 'equides' field in the document with an empty list
      await documentRef.update({'equides': []});
    } catch (e) {
      // Handle errors
      print('Error removing all equides for compte with id $cmptId: $e');
      throw e;
    }
  }

  @override
  Future<void> removeOneEquide(String cmptId, String equideId) async {
    try {
      // Get a reference to the specific document in the 'comptes' collection
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);
      // Get the current data of the document
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};

      // Extract the equides field from the data, or create an empty list if it doesn't exist
      List<Map<String, dynamic>> currentEquides =
          (data['equides'] as List<Map<String, dynamic>>?) ?? [];

      // Remove the equide with the specified id from the list
      currentEquides.removeWhere((equide) => equide['id'] == equideId);

      // Update the 'equides' field in the document with the modified list
      await documentRef.update({'equides': currentEquides});
    } catch (e) {
      // Handle errors
      print('Error removing equide with id $equideId: $e');
      throw e;
    }
  }

  @override
  Future<List<Equide>?> addNewListeEquide(
      String cmptId, List<Equide> equides) async {
    try {
      // Get a reference to the specific document in the 'comptes' collection
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);

      // Get the current data of the document
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};

      // Extract the equides field from the data, or create an empty list if it doesn't exist
      List<Map<String, dynamic>> currentEquides = [];

      if (data.containsKey('equides') && data['equides'] is List) {
        // Vérifiez d'abord que 'equides' est de type List avant de le convertir
        currentEquides =
            (data['equides'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      }

      print('Current Equides: $currentEquides');

      // Convert the Equide objects to a list of Map<String, dynamic>
      List<Map<String, dynamic>> newEquides =
          equides.map((equide) => equide.toJson()).toList();

      print('New Equides: $newEquides');

      // Combine the current and new equides lists
      List<Map<String, dynamic>> updatedEquides = [
        ...currentEquides,
        ...newEquides
      ];

      print('Updated Equides: $updatedEquides');

      // Update the 'equides' field in the document with the combined list
      await documentRef.update({'equides': updatedEquides});

      // Return the updated list of equides
      return updatedEquides
          .map((equideData) => Equide.fromJson(equideData))
          .toList();
    } catch (e) {
      // Handle errors
      print('Error adding new list of equides: $e');
      throw e;
    }
  }

  @override
  Future<void> deleteEpreuve(String chevalId, String epreuveId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Epreuve>?> readAllEpreuves(String cmptId, String idCheval) async {
    try {
      // Récupérez la référence du document du compte
      final compteRef =
          Firestore.instance.collection('comptes').document(cmptId);
      // Récupérez les données actuelles du compte
      final compteSnapshot = await compteRef.get();
      final Map<String, dynamic> compteData = compteSnapshot.map;

      // Récupérez la liste des chevaux du compte
      final List<Map<String, dynamic>> chevauxData =
          compteData['chevaux'] as List<Map<String, dynamic>> ?? [];

      // Recherchez le cheval par son ID dans la liste
      final Map<String, dynamic>? chevalData =
          chevauxData.firstWhere((cheval) => cheval['id'] == idCheval);

      if (chevalData != null) {
        // Récupérez la liste d'épreuves du cheval
        final List<Map<String, dynamic>> epreuvesData =
            chevalData['epreuves'] as List<Map<String, dynamic>> ?? [];

        // Transformez les données des épreuves en objets Epreuve
        final List<Epreuve> allEpreuves = epreuvesData
            .map((epreuveData) => Epreuve.fromJson(epreuveData))
            .toList();

        return allEpreuves;
      } else {
        // Le cheval n'a pas été trouvé dans la liste
        return Future.error('Cheval not found');
      }
    } catch (e) {
      print('Error reading epreuves: $e');
      throw e;
    }
  }

  @override
  Future<List<Evenement>> readAllEvenements(String cmptId) async {
    try {
      final List<Evenement> evenements = [];

      var querySnapshot = await _firestore
          .collection('comptes')
          .document(cmptId)
          .collection('evenements')
          .get()
          .then((event) {
        for (final doc in event) {
          evenements.add(Evenement.fromJson(doc.map));
        }
      });
      return evenements;
    } catch (e) {
      print('Error reading all evenements: $e');
      throw e;
    }
  }

  @override
  @override
  Future<List<Evenement>?> addEvenement(String userId, Evenement event) async {
    try {
      print("hello");
      // Récupérer le document du compte à partir de son ID
      final accountRef = _firestore.collection('comptes').document(userId);
      final accountDoc = await accountRef.get();

      // Vérifier si le document du compte existe
      if (accountDoc != null) {
        // Récupérer la liste actuelle des événements du compte
        List<dynamic> evenementsData =
            (accountDoc.map?['evenements'] ?? []) as List<dynamic>;

        List<Map<String, dynamic>> evenements = [];

        // Convertir chaque événement en un map
        for (var evenementData in evenementsData) {
          if (evenementData is Map<String, dynamic>) {
            evenements.add(evenementData);
          }
        }

        // Ajouter le nouvel événement à la liste
        evenements.add(event.toJson());

        // Mettre à jour le champ 'evenements[]' du document du compte
        await accountRef.update({'evenements': evenements});

        print('Événement ajouté avec succès au compte $userId');

        // Retourner la liste mise à jour des événements
        return evenements
            .map((eventJson) => Evenement.fromJson(eventJson))
            .toList();
      } else {
        print('Le document du compte avec l\'ID $userId n\'existe pas.');
        throw Exception(
            'Le document du compte avec l\'ID $userId n\'existe pas.');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'événement: $e');
      throw e;
    }
  }

  @override
  Future<Epreuve?> addEpreuve(
      String userId, String chevalId, List<String> epreuveIds) async {
    try {
      // Récupérer le compte depuis la base de données Firebase
      var documentSnapshot =
          await Firestore.instance.collection('comptes').document(userId).get();
      final Map<String, dynamic> compteData = documentSnapshot.map ?? {};

      // Assurez-vous que le cheval existe
      if (compteData['equides'] == null) {
        return Future.error('Cheval not found');
      }

      // Trouvez le cheval par son ID
      final cheval = (compteData['equides'] as List<dynamic>)
          .firstWhere((equide) => equide['id'] == chevalId, orElse: () => null);

      // Vérifiez si le cheval existe
      if (cheval == null) {
        return Future.error('Cheval not found');
      }

      // Initialisez la liste des épreuves si elle est null
      if (cheval['epreuves'] == null) {
        cheval['epreuves'] = [];
      }

      // Ajoutez les épreuves à la liste
      for (final epreuveId in epreuveIds) {
        // Récupérer l'épreuve depuis la base de données Firebase
        var epreuveSnapshot = await Firestore.instance
            .collection('epreuves')
            .document(epreuveId)
            .get();

        final Map<String, dynamic> epreuveData = epreuveSnapshot.map ?? {};

        final epreuve = Epreuve.fromJson(epreuveData);
        cheval['epreuves'].add(epreuve.toJson());
      }
// Mettez à jour le document dans la base de données
      await documentSnapshot.reference
          .update({'equides': compteData['equides']});

      return Epreuve.fromJson(cheval['epreuves'].first as Map<String, dynamic>);
    } catch (e) {
      print('Error adding epreuve: $e');
      throw e;
    }
  }

  Future<void> updateExercice(
      String id, int index, String idCpt, bool statusExo) async {
    try {
      // Récupérez une référence au document Firebase correspondant au compte
      var compteSnapshot =
          await _firestore.collection('comptes').document(idCpt).get();
      if (compteSnapshot == null) {
        print('Compte with id $idCpt not found');
        return;
      }

      // Obtenir la liste des entraînements du compte
      var entrainements = compteSnapshot['entrainements'] as List;

      // Vérifiez si l'index fourni est valide
      if (index >= 0 && index < entrainements.length) {
        // Obtenir l'entraînement spécifique par son index dans la liste des entraînements
        var entrainement = entrainements[index];

        // Obtenir la liste des exercices de l'entraînement
        var exercices = entrainement['exerciceIds'] as List;

        // Recherchez l'exercice spécifique par son ID dans la liste des exercices
        var exerciceIndex =
            exercices.indexWhere((exercice) => exercice['id'] == id);

        if (exerciceIndex != -1) {
          // Mettez à jour le champ status de l'exercice existant avec la nouvelle valeur
          exercices[exerciceIndex]['status'] = statusExo;

          // Mettez à jour les données de l'entraînement avec les exercices mis à jour
          entrainement['exerciceIds'] = exercices;

          // Mettez à jour les données du compte avec l'entraînement mis à jour
          entrainements[index] = entrainement;
          print("entrainement : $entrainement");

          // Mettez à jour les données du compte avec les entraînements mis à jour
          await _firestore.collection('comptes').document(idCpt).update({
            'entrainements': entrainements,
          });

          print('Exercice with id $id updated successfully');
        } else {
          print('Exercice with id $id not found in training at index $index');
        }
      } else {
        print('Invalid index: $index');
      }
    } catch (e) {
      // Gérez les erreurs
      print('Error updating exercice: $e');
      throw e;
    }
  }

  @override
  Future<Compte> update(String id, Compte cmpt) async {
    try {
      // Instantiate a reference to the specific document in the 'comptes' collection
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(id);

      // Update the document with the new data
      await documentRef.update({
        'email': cmpt.email,
        'passwordHash': cmpt.passwordHash,
        // Add other fields as needed
      });

      return cmpt;
    } catch (e) {
      // Handle errors
      print('Error updating account: $e');
      throw e;
    }
  }
// Importez la classe Exercice

  Future<Exercice?> getExerciceById(String id, int index, String idCpt) async {
    try {
      // Récupérez une référence au document Firebase correspondant à l'exercice
      var compteSnapshot =
          await _firestore.collection('comptes').document(idCpt).get();
      if (compteSnapshot == null) {
        print('Compte with id $idCpt not found');
        return null;
      }

      // Obtenir la liste des exercices de l'entraînement
      var entrainements = compteSnapshot.map['entrainements'] as List<dynamic>;
      var entrainement = entrainements[index];

      // Obtenir la liste des exercices de l'entraînement
      var exercices = entrainement['exerciceIds'] as List;

      // Recherchez l'exercice spécifique par son ID dans la liste des exercices
      var exercice = exercices.firstWhere(
        (exercice) => exercice['id'] == id,
        orElse: () => null,
      );

      if (exercice == null) {
        print('Exercice with id $id not found in training');
        return null;
      }

      // Créez un objet Exercice à partir des données récupérées
      return Exercice.fromJson(exercice as Map<String, dynamic>);
    } catch (e) {
      print('Error getting exercice: $e');
      return null;
    }
  }

  @override
  Future<bool> authenticateUser(String email, String password) async {
    var tokenStore = MyCustomTokenStore();
    final firebaseAuth = FirebaseAuth.initialize(
        'AIzaSyDRzzZT9gYFShI9OnWuosB80SXtEDg4p2c', tokenStore);
    try {
      var userCredential = await FirebaseAuth.instance.signIn(email, password);
      print(await FirebaseAuth.instance.getUser());
      if (userCredential.email != null) {
        return true; // Authentification réussie
      } else {
        return false; // Authentification échouée
      }
    } catch (e) {
      print('Authentication error: $e');
      return false; // Authentification échouée
    }
  }

  @override
  Future<String?> getDocumentReferenceByEmail(String? email) async {
    try {
      // Effectuer une requête pour trouver le document correspondant à l'email
      var querySnapshot = await Firestore.instance
          .collection('comptes')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Vérifier si des documents ont été trouvés
      if (querySnapshot.isNotEmpty) {
        // Parcourir les documents pour obtenir les références
        for (var document in querySnapshot) {
          var docReference = document.id;
          return docReference;
        }
      } else {
        // Aucun document trouvé avec cet email
        print('Aucun document trouvé avec l\'email : $email');
        return null;
      }
    } catch (e) {
      // Gérer les erreurs
      print('Erreur lors de la récupération de la référence du document : $e');
      return null;
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }
}

class MyCustomTokenStore implements TokenStore {
  String? _token;

  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  void delete() {
    // TODO: implement delete
  }

  @override
  void expireToken() {
    // TODO: implement expireToken
  }

  @override
  // TODO: implement expiry
  DateTime? get expiry => throw UnimplementedError();

  @override
  // TODO: implement hasToken
  bool get hasToken => throw UnimplementedError();

  @override
  // TODO: implement idToken
  String? get idToken => throw UnimplementedError();

  @override
  Token? read() {
    return _token != null
        ? Token(
            _token!,
            DateTime.now().add(const Duration(hours: 1)).toString(),
            DateTime.now().toString(),
            DateTime.now())
        : null;
  }

  @override
  // TODO: implement refreshToken
  String? get refreshToken => throw UnimplementedError();

  @override
  void setToken(
      String? userId, String idToken, String refreshToken, int expiresIn) {
    // TODO: implement setToken
  }

  @override
  // TODO: implement userId
  String? get userId => throw UnimplementedError();

  @override
  void write(Token? token) {
    if (token != null) {
      _token = token as String?;
    }
  }
}
