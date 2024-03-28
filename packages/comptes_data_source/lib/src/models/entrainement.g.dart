// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entrainement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entrainement _$EntrainementFromJson(Map<String, dynamic> json) => Entrainement(
      compteId: json['compteId'] as String,
      exerciceIds: (json['exerciceIds'] as List<dynamic>)
          .map((e) => Exercice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EntrainementToJson(Entrainement instance) =>
    <String, dynamic>{
      'compteId': instance.compteId,
      'exerciceIds': instance.exerciceIds,
    };
