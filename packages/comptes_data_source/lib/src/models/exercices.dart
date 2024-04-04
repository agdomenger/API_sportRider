import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
part 'exercices.g.dart';

//liste des catégories que l'on peut affilier à un exercice
enum CATEGORIES {
  deb_moins16,
  deb_16_40,
  deb_plus40,
  club_moins16,
  club_16_40,
  club_plus40,
  amat_moins16,
  amat_16_40,
  amat_plus40,
  pro_moins16,
  pro_16_40,
  prot_plus40,
}

/*
un exercice c'est un status : fait ou opas fait 
une catégorie et une description 
 */
@immutable
@JsonSerializable()
class Exercice extends Equatable {
  Exercice({
    this.id,
    this.status,
    required this.description,
    required this.categorie,
    this.url,
  }) : assert(id == null || id.isNotEmpty, 'id cannot be empty');
  final String? id;
  final String description;
  bool? status;
  CATEGORIES categorie;
  String? url;

  Exercice copyWith({
    String? id,
    String? description,
    CATEGORIES? categorie,
    bool? status,
    String? url,
  }) {
    return Exercice(
      id: id ?? this.id,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
      status: status ?? this.status,
      url: url ?? url,
    );
  }

  static Exercice fromJson(Map<String, dynamic> json) =>
      _$ExerciceFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciceToJson(this);
  static CATEGORIES _getCategorie(String categorie) {
    return CATEGORIES.values.firstWhere(
      (e) => e.toString().split('.').last == categorie,
      orElse: () =>
          CATEGORIES.deb_moins16, // Default value or handle differently
    );
  }

  static String _getEnumValue(CATEGORIES categorie) {
    return categorie.toString().split('.').last;
  }

  @override
  List<Object?> get props => [id, description, status, categorie, url];
}
