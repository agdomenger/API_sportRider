import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entrainement.g.dart';

@JsonSerializable()
class Entrainement {
  final String compteId;
  final List<Exercice> exerciceIds;

  Entrainement({
    required this.compteId,
    required this.exerciceIds,
  });

  factory Entrainement.fromJson(Map<String, dynamic> json) {
    return Entrainement(
      compteId: json['compteId'] as String,
      exerciceIds: (json['exerciceIds'] as List<dynamic>).map((exerciceJson) {
        if (exerciceJson is Map<String, dynamic>) {
          return Exercice.fromJson(exerciceJson);
        } else {
          // Gérer le cas où exerciceJson n'est pas une Map<String, dynamic>
          // Par exemple, renvoyer un objet Exercice par défaut ou lever une erreur.
          throw FormatException('Invalid exercice data');
        }
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compteId': compteId,
      'exerciceIds': exerciceIds.map((exercice) => exercice.toJson()).toList(),
    };
  }
}
