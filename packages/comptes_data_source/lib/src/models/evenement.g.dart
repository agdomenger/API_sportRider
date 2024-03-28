// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evenement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Evenement _$EvenementFromJson(Map<String, dynamic> json) => Evenement(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      titre: json['titre'] as String,
      description: json['description'] as String?,
      equide: json['equide'] == null
          ? null
          : Equide.fromJson(json['equide'] as Map<String, dynamic>),
      compte: json['compte'] == null
          ? null
          : Compte.fromJson(json['compte'] as Map<String, dynamic>),
      public: json['public'] as bool?,
      tag: json['tag'] as String,
    );

Map<String, dynamic> _$EvenementToJson(Evenement instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'titre': instance.titre,
      'tag': instance.tag,
      'description': instance.description,
      'equide': instance.equide,
      'compte': instance.compte,
      'public': instance.public,
    };
