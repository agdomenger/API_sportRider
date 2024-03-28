// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epreuve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Epreuve _$EpreuveFromJson(Map<String, dynamic> json) => Epreuve(
      id: json['id'] as String?,
      niveau: $enumDecode(_$NiveauEnumMap, json['niveau']),
      discipline: $enumDecode(_$DisciplineEnumMap, json['discipline']),
      categorie: $enumDecode(_$CategorieEnumMap, json['categorie']),
    );

Map<String, dynamic> _$EpreuveToJson(Epreuve instance) => <String, dynamic>{
      'id': instance.id,
      'niveau': _$NiveauEnumMap[instance.niveau]!,
      'discipline': _$DisciplineEnumMap[instance.discipline]!,
      'categorie': _$CategorieEnumMap[instance.categorie]!,
    };

const _$NiveauEnumMap = {
  Niveau.un: 'un',
  Niveau.deux: 'deux',
  Niveau.trois: 'trois',
  Niveau.quatre: 'quatre',
  Niveau.elite: 'elite',
};

const _$DisciplineEnumMap = {
  Discipline.cce: 'cce',
  Discipline.cso: 'cso',
  Discipline.dressage: 'dressage',
  Discipline.voltige: 'voltige',
  Discipline.endurance: 'endurance',
  Discipline.trec: 'trec',
  Discipline.hunter: 'hunter',
  Discipline.ponyGame: 'ponyGame',
};

const _$CategorieEnumMap = {
  Categorie.amat: 'amat',
  Categorie.club: 'club',
  Categorie.pro: 'pro',
  Categorie.debutant: 'debutant',
};
