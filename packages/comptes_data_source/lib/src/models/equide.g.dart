// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Equide _$EquideFromJson(Map<String, dynamic> json) => Equide(
      id: json['id'] as String?,
      elevage: json['elevage'] as String?,
      nom: json['nom'] as String,
      anneeNaissance: json['anneeNaissance'] as int,
      epreuves: (json['epreuves'] as List<dynamic>?)
          ?.map((e) => Epreuve.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EquideToJson(Equide instance) => <String, dynamic>{
      'id': instance.id,
      'elevage': instance.elevage,
      'nom': instance.nom,
      'anneeNaissance': instance.anneeNaissance,
      'epreuves': instance.epreuves,
    };
