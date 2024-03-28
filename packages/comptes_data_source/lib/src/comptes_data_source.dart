import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:comptes_data_source/src/models/evenement.dart';

/// An interface for a todos data source.
/// A todos data source supports basic C.R.U.D operations.
/// * C - Create
/// * R - Read
/// * U - Update
/// * D - Delete
abstract class ComptesDataSource {
  Future<List<Compte>> readAll();

  Future<Compte?> create(Compte cmpt);

  Future<Compte?> read(String id);

  Future<Compte?> update(String id, Compte cmpt);

  Future<void> delete(String id);
  Future<void> updateExercice(
      String id, int index, String idCpt, bool statusExo);
  Future<Exercice?> getExerciceById(String id, int index, String idCpt);
  Future<Compte?> findCompteByEmailAndPassword(String email, String password);
  Future<List<Entrainement>?> readAllEntrainementsCompte(String cmpt_id);
  Future<List<Map<String, dynamic>>?> readAllEntrainements();
  Future<List<Equide>?> readAllEquides(String cmptId);

  Future<List<Equide>?> addNewListeEquide(String cmptId, List<Equide> equide);
  Future<void> logoutUser();
  Future<void> removeOneEquide(String cmptId, String idEquide);

  Future<void> removeAllEquides(String cmptId);
  Future<List<Entrainement>?> createEntrainement(
      String compteId, List<String> exerciceIndices);
  Future<Exercice> createExercice(Exercice entrainement);
  Future<List<Evenement>?> addEvenement(String cmptId, Evenement event);
  Future<List<Evenement>> readAllEvenements(String cmptId);
  Future<List<String>> readAllExercice();
  Future<bool> authenticateUser(String email, String password);

  Future<List<Epreuve>?> readAllEpreuves(String cmptId, String idCheval);

  Future<Epreuve> createEpreuve(Epreuve epreuve);

  Future<Epreuve?> addEpreuve(
      String userId, String chevalId, List<String> epreuveId);

  Future<void> deleteEpreuve(String chevalId, String epreuveId);

  Future<String?> getDocumentReferenceByEmail(String? string);

  Future<dynamic> getCurrentUser();

  Future<Map<String, dynamic>?> getUserInfoById(String userId);
}
