// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comptes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Compte _$CompteFromJson(Map<String, dynamic> json) => Compte(
      id: json['id'] as String?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      salt: json['salt'] as String?,
      entrainements: (json['entrainements'] as List<dynamic>?)
          ?.map((e) => Entrainement.fromJson(e as Map<String, dynamic>))
          .toList(),
      equides: (json['equides'] as List<dynamic>?)
          ?.map((e) => Equide.fromJson(e as Map<String, dynamic>))
          .toList(),
      evenements: (json['evenements'] as List<dynamic>?)
          ?.map((e) => Evenement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompteToJson(Compte instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'equides': instance.equides,
      'evenements': instance.evenements,
      'entrainements': instance.entrainements,
      'passwordHash': instance.passwordHash,
      'salt': instance.salt,
    };
