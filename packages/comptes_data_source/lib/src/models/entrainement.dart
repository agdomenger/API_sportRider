import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entrainement.g.dart';

/*
un entrainement contient : 
obligatoirement un compte et une liste d'id d'exercices
 */
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
