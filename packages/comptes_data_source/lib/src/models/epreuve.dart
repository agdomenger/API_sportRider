// epreuve.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'epreuve.g.dart';

/*
Une épreuve est l'aliance entre un niveau, une discipline et une catégorie 
 */
@immutable
@JsonSerializable()
class Epreuve extends Equatable {
  Epreuve({
    this.id,
    required this.niveau,
    required this.discipline,
    required this.categorie,
  });

  final String? id;
  final Niveau niveau;
  final Discipline discipline;
  final Categorie categorie;

  static Epreuve fromJson(Map<String, dynamic> json) => _$EpreuveFromJson(json);

  Map<String, dynamic> toJson() => _$EpreuveToJson(this);

  @override
  List<Object?> get props => [id, niveau, discipline, categorie];
  static Niveau _getNiveau(String niveau) {
    return Niveau.values.firstWhere(
      (e) => e.toString().split('.').last == niveau,
      orElse: () => Niveau.un, // Default value or handle differently
    );
  }

  static Discipline _getDiscipline(String discipline) {
    return Discipline.values.firstWhere(
      (e) => e.toString().split('.').last == discipline,
      orElse: () => Discipline.cce, // Default value or handle differently
    );
  }

  static Categorie _getCategorie(String categorie) {
    return Categorie.values.firstWhere(
      (e) => e.toString().split('.').last == categorie,
      orElse: () => Categorie.amat, // Default value or handle differently
    );
  }

  static String _getEnumValue(String categorie) {
    return categorie.split('.').last;
  }

  Epreuve copyWith({
    String? id,
    Niveau? niveau,
    Discipline? discipline,
    Categorie? categorie,
  }) {
    return Epreuve(
        id: id ?? this.id,
        niveau: niveau ?? this.niveau,
        categorie: categorie ?? this.categorie,
        discipline: discipline ?? this.discipline);
  }
}

/*Enumération des niveaux possibles */
enum Niveau {
  un,
  deux,
  trois,
  quatre,
  elite,
}

/*Enumération des disciplines existantes  */
enum Discipline {
  cce,
  cso,
  dressage,
  voltige,
  endurance,
  trec,
  hunter,
  ponyGame,
}

/*Enumération des catégories possibles */
enum Categorie { amat, club, pro, debutant }
