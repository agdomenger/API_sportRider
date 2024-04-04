import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:comptes_data_source/src/models/entrainement.dart';
import 'package:comptes_data_source/src/models/equide.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
part 'evenement.g.dart';

/*
un evenement c'est : 
une date et un titre
on peut y ajouter une description 
mais aussi un cheval, on utilisera ça plus tard dans l'application
le champ public sera utile plus tard pour proposer des evenement à tout les comptes
 */
@immutable
@JsonSerializable()
class Evenement extends Equatable {
  Evenement({
    this.id,
    required this.date,
    required this.titre,
    this.description,
    this.equide,
    this.compte,
    this.public,
    required this.tag,
  }) : assert(id == null || id.isNotEmpty, 'id cannot be empty');

  final String? id;
  final DateTime date;
  final String titre;
  final String tag;
  final String? description;
  final Equide? equide;
  final Compte? compte;
  final bool? public;

  static Evenement fromJson(Map<String, dynamic> json) =>
      _$EvenementFromJson(json);

  Map<String, dynamic> toJson() => _$EvenementToJson(this);

  @override
  List<Object?> get props =>
      [id, date, tag, titre, description, equide, compte, public];

  Evenement copyWith(
      {String? id,
      DateTime? date,
      String? titre,
      String? description,
      Equide? equide,
      Compte? compte,
      String? tag,
      bool? public}) {
    return Evenement(
      tag: tag ?? this.tag,
      id: id ?? this.id,
      titre: titre ?? this.titre,
      compte: compte ?? this.compte,
      description: description ?? this.description,
      equide: equide ?? this.equide,
      public: public ?? this.public,
      date: date ?? this.date,
    );
  }
}
