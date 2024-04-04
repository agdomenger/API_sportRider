import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';
part 'equide.g.dart';

/*
Un équidé est composé de : 
un nom, une année de naissance mais aussi un nom d'élevage qu'on peut ajouter un un type d'epreuve
 */
@immutable
@JsonSerializable()
class Equide extends Equatable {
  Equide({
    String? id,
    this.elevage,
    required this.nom,
    required this.anneeNaissance,
    this.epreuves,
  }) : id = id ?? const Uuid().v4(); //id généré automatiquement

  final String? id;
  final String? elevage;
  final String nom;
  final int anneeNaissance;
  late List<Epreuve>? epreuves;

  static Equide fromJson(Map<String, dynamic> json) => _$EquideFromJson(json);

  Map<String, dynamic> toJson() => _$EquideToJson(this);

  @override
  List<Object?> get props => [id, elevage, nom, anneeNaissance, epreuves];

  Equide copyWith({
    String? id,
    String? nom,
    List<Epreuve>? epreuves,
    String? elevage,
    int? anneeNaissance,
  }) {
    return Equide(
        id: id ?? this.id,
        anneeNaissance: anneeNaissance ?? this.anneeNaissance,
        nom: nom ?? this.nom,
        elevage: elevage ?? this.elevage,
        epreuves: epreuves ?? this.epreuves);
  }
}
