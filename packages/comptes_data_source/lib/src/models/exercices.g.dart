// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercice _$ExerciceFromJson(Map<String, dynamic> json) => Exercice(
      id: json['id'] as String?,
      status: json['status'] as bool?,
      description: json['description'] as String,
      categorie: $enumDecode(_$CATEGORIESEnumMap, json['categorie']),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ExerciceToJson(Exercice instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'status': instance.status,
      'categorie': _$CATEGORIESEnumMap[instance.categorie]!,
      'url': instance.url,
    };

const _$CATEGORIESEnumMap = {
  CATEGORIES.deb_moins16: 'deb_moins16',
  CATEGORIES.deb_16_40: 'deb_16_40',
  CATEGORIES.deb_plus40: 'deb_plus40',
  CATEGORIES.club_moins16: 'club_moins16',
  CATEGORIES.club_16_40: 'club_16_40',
  CATEGORIES.club_plus40: 'club_plus40',
  CATEGORIES.amat_moins16: 'amat_moins16',
  CATEGORIES.amat_16_40: 'amat_16_40',
  CATEGORIES.amat_plus40: 'amat_plus40',
  CATEGORIES.pro_moins16: 'pro_moins16',
  CATEGORIES.pro_16_40: 'pro_16_40',
  CATEGORIES.prot_plus40: 'prot_plus40',
};
