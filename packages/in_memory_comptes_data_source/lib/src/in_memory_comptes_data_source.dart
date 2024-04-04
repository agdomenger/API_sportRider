import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:comptes_data_source/src/models/evenement.dart';
import 'package:firedart/firedart.dart';

import 'package:uuid/uuid.dart';

/// An in-memory implementation of the [ComptesDataSource] interface.
class InMemoryComptesDataSource implements ComptesDataSource {
  /// Map of ID -> Comptes
  // créer une instance firestore
  final Firestore _firestore = Firestore.instance;

/*
fonction permetant de récuperer l'insatnce de l'utilisateur courent */
  Future<dynamic> getCurrentUser() async {
    try {
      var currentUser = await FirebaseAuth.instance.getUser();
      return currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

/*
fonction de création du compte
 */
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

/*
fonction renvoyant tout les comptes existants 
*/
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

/*
retourne les informations de l'utilisateur à partir de son ID */
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

/*
renvoie les infos du document firebase à partir de l'id du compte
 */
  @override
  Future<Compte?> read(String id) async {
    try {
      // récuperation du document firebase representant le compte
      DocumentReference documentRef =
          Firestore.instance.collection("comptes").document(id);

      var document = await documentRef.get();
      // regarder si ce document existe
      if (document != null) {
        var dataa = document.map;
        final Compte compte = Compte.fromJson(dataa);
        return compte;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error reading account with id $id: $e');
      throw e;
    }
  }

/*
supprimer un compte 
 */
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

/*
trouve  et renvoie l'insatnce associée à un compte à partir de son email et mot de passe 
 */
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

/*
création d'un entrainement à partir de l'id du compte concerné et d'une liste d'id d'exercices
 */
  @override
  Future<List<Entrainement>?> createEntrainement(
      String compteId, List<String> exerciceIds) async {
    try {
      // recuperer le document firebase associé au compte
      var documentRef =
          Firestore.instance.collection('comptes').document(compteId);

      // recuperer les information du document
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};
      print('Document Data: $data');

      List<Map<String, dynamic>> entrainementsData = [];

      if (data['entrainements'] is List<dynamic>) {
        entrainementsData = (data['entrainements'] as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      List<Exercice> selectedExercices = [];

      for (String exerciceId in exerciceIds) {
        var exerciceSnapshot = await Firestore.instance
            .collection('exercices')
            .document(exerciceId)
            .get();
        Map<String, dynamic> exerciceData = exerciceSnapshot.map ?? {};
        selectedExercices.add(Exercice.fromJson(exerciceData));
      }
      print(selectedExercices.toString());

      //si la liste existe
      if (selectedExercices.isNotEmpty) {
        //creer un entrainement
        final entrainement = Entrainement(
          compteId: compteId,
          exerciceIds: selectedExercices,
        );
        // combiné la liste existante et celle que l'on veut ajouter
        List<Map<String, dynamic>> updatedEntrainements = [
          ...entrainementsData,
          entrainement.toJson(),
        ];

        // mettre a jour le doc firebase
        await documentRef.update({'entrainements': updatedEntrainements});
        print('5');
        return updatedEntrainements
            .map((json) => Entrainement.fromJson(json))
            .toList();
      } else {
        // pas d'exercice ids
        return Future.error('les ids exercices fournis ne sont pas valident ');
      }
    } catch (e) {
      // Handle errors
      print('Error creating entrainement for compte with id $compteId: $e');
      throw e;
    }
  }

/*
créer un exercice
 */
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

/*
créer une epreuve
 */
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
      });

      return createdEpreuve;
    } catch (e) {
      // Handle errors
      print('Error creating epreuve: $e');
      throw e;
    }
  }

/*
récupération de tout les exercices existants
 */
  Future<List<String>> readAllExercice() async {
    try {
      final List<String> exerciceIds = [];

      // Référence de la collection 'exercices'
      final CollectionReference exercicesRef =
          Firestore.instance.collection('exercices');

      // Otous les documents de la collection 'exercices'
      final Page<Document> page = await exercicesRef.get();

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

/*
renvoie tout les entrainements existants 
pas vraiment d'utilité pour l'instant en fait
 */
  @override
  Future<List<Map<String, dynamic>>?> readAllEntrainements() async {
    try {
      final List<Map<String, dynamic>> entrainementsDetails = [];
      var querySnapshot =
          await Firestore.instance.collection('comptes').get().then((event) {
        //parcourir tous les comptes
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
      print('Error retrieving entrainements details: $e');
      throw e;
    }
  }

/*
renvoie tout les entrainements d'un compte 
 */
  @override
  Future<List<Entrainement>?> readAllEntrainementsCompte(
      String compteId) async {
    try {
      var documentRef = _firestore.collection('comptes').document(compteId);
      var documentSnapshot = await documentRef.get();

      //si le doc existe
      if (documentSnapshot != null) {
        //recuperer les entrainements
        List<dynamic>? entrainementsData =
            documentSnapshot.map?['entrainements'] as List<dynamic>?;
        if (entrainementsData != null) {
          // convertir en liste d'entrainement
          List<Entrainement> entrainements = entrainementsData
              .map((entrainement) =>
                  Entrainement.fromJson(entrainement as Map<String, dynamic>))
              .toList();

          return entrainements;
        } else {
          // pas d'entrainement trouvé
          return [];
        }
      } else {
        // Document n'existe pas
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error reading entrainements for compte with id $compteId: $e');
      throw e;
    }
  }

/*
récuperer tout les équidés d'un compte */
  @override
  Future<List<Equide>?> readAllEquides(String cmptId) async {
    try {
      // recuperer la reference du compte
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);
      // récupération des infos
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};

      // récuperer les equides
      List<Map<String, dynamic>>? equidesData =
          data['equides'] as List<Map<String, dynamic>>?;

      if (equidesData != null) {
        List<Equide> equides = equidesData
            .map((equideData) => Equide.fromJson(equideData))
            .toList();
        return equides;
      } else {
        return null;
      }
    } catch (e) {
      print('Error reading equides for compte with id $cmptId: $e');
      throw e;
    }
  }

/*
supprimer tous les equides du compte 
 */
  @override
  Future<void> removeAllEquides(String cmptId) async {
    try {
      //récupération de la réference du compte
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);
      //mise a jour de la liste dans firebase
      await documentRef.update({'equides': []});
    } catch (e) {
      print('Error removing all equides for compte with id $cmptId: $e');
      throw e;
    }
  }

/*
supprimer un équidé spécifique du compte
 */
  @override
  Future<void> removeOneEquide(String cmptId, String equideId) async {
    try {
      //récuperer la réference du compte
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);
      // récuperer les données
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};

      // récuperer la liste des equides
      List<Map<String, dynamic>> currentEquides =
          (data['equides'] as List<Map<String, dynamic>>?) ?? [];

      // supprimer le chavl ayant l'id fourni
      currentEquides.removeWhere((equide) => equide['id'] == equideId);

      //mise a jour dans firebase
      await documentRef.update({'equides': currentEquides});
    } catch (e) {
      print('Error removing equide with id $equideId: $e');
      throw e;
    }
  }

/*
ajouter une nouvelle liste d'équide
 */
  @override
  Future<List<Equide>?> addNewListeEquide(
      String cmptId, List<Equide> equides) async {
    try {
      // récuperer la réference
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(cmptId);

      // récuperer les données
      var documentSnapshot = await documentRef.get();
      Map<String, dynamic> data = documentSnapshot.map ?? {};
      List<Map<String, dynamic>> currentEquides = [];

      if (data.containsKey('equides') && data['equides'] is List) {
        currentEquides =
            (data['equides'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      }

      print('Current Equides: $currentEquides');
      List<Map<String, dynamic>> newEquides =
          equides.map((equide) => equide.toJson()).toList();

      print('New Equides: $newEquides');

// fusionner la liste existante et la nouvelle
      List<Map<String, dynamic>> updatedEquides = [
        ...currentEquides,
        ...newEquides
      ];

      print('Updated Equides: $updatedEquides');

      await documentRef.update({'equides': updatedEquides});

      return updatedEquides
          .map((equideData) => Equide.fromJson(equideData))
          .toList();
    } catch (e) {
      print('Error adding new list of equides: $e');
      throw e;
    }
  }

/*
supprimer une epreuve 
non implémenter
 */
  @override
  Future<void> deleteEpreuve(String chevalId, String epreuveId) {
    throw UnimplementedError();
  }

/*récupération de toutes les epreuves crées*/
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

/*
récuperer tous les evenements 
 */
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

/*
ajouter une evenement 
 */
  @override
  Future<List<Evenement>?> addEvenement(String userId, Evenement event) async {
    try {
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

/*
ajouter une epreuve à un cheval
 */
  @override
  Future<Epreuve?> addEpreuve(
      String userId, String chevalId, List<String> epreuveIds) async {
    try {
      // Récupérer le compte depuis la base de données Firebase
      var documentSnapshot =
          await Firestore.instance.collection('comptes').document(userId).get();
      final Map<String, dynamic> compteData = documentSnapshot.map ?? {};

      // vérifier que le cheval existe
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

/*
mettre à jour un exercice
non utilisé 
 */
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
          // Mettre à jour le champ status de l'exercice existant avec la nouvelle valeur
          exercices[exerciceIndex]['status'] = statusExo;

          // Mettre à jour les données de l'entraînement avec les exercices mis à jour
          entrainement['exerciceIds'] = exercices;

          // Mettre à jour les données du compte avec l'entraînement mis à jour
          entrainements[index] = entrainement;
          print("entrainement : $entrainement");

          // Mettre à jour les données du compte avec les entraînements mis à jour
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

/*
mettre à jour le compte
non utilisé 
 */
  @override
  Future<Compte> update(String id, Compte cmpt) async {
    try {
      //reference du compte
      DocumentReference documentRef =
          Firestore.instance.collection('comptes').document(id);

      // mettre a jour le doc firebase
      await documentRef.update({
        'email': cmpt.email,
        'passwordHash': cmpt.passwordHash,
      });

      return cmpt;
    } catch (e) {
      print('Error updating account: $e');
      throw e;
    }
  }

/*
récuperer l'exercice d'un compte et d'un entrainement donné
utile pour changer le status après par exemple
 */
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

/*
permet d'authentifier l'utilisateur pendant la connexion
 */
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

/*
recuperer la reference firebase d'un compte à partir de l'adresse email
*/
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

/*
permet de deconnecter un utilisateur 
 */
  @override
  Future<void> logoutUser() async {
    try {
      FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }
}

/*
gestion des token fait maison un peu bancale ^^ 
*/
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
