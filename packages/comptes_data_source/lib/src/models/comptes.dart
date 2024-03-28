import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:comptes_data_source/src/models/entrainement.dart';
import 'package:comptes_data_source/src/models/equide.dart';
import 'package:comptes_data_source/src/models/evenement.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';
part 'comptes.g.dart';

@immutable
@JsonSerializable()
class Compte extends Equatable {
  Compte({
    this.id,
    this.nom,
    this.prenom,
    required this.email,
    required this.passwordHash,
    this.salt,
    this.entrainements,
    this.equides,
    this.evenements,
  }) : assert(id == null || id.isNotEmpty, 'id cannot be empty');

  final String? id;
  final String email;
  String? nom;
  String? prenom;
  List<Equide>? equides;
  List<Evenement>? evenements;
  List<Entrainement>? entrainements;
  String passwordHash;
  String? salt;

  // Nouvelle méthode pour définir le mot de passe avec hachage et sel
  void setPassword(String password) {
    final Uint8List randomBytes = Uint8List(32);
    final Random secureRandom = Random.secure();
    for (int i = 0; i < randomBytes.length; i++) {
      randomBytes[i] = secureRandom.nextInt(256);
    }

    final String salt = base64.encode(randomBytes);
    final String hashedPassword = _hashPassword(password, salt);

    this.passwordHash = hashedPassword;
    this.salt = salt;
  }

  // Nouvelle méthode pour vérifier le mot de passe
  bool checkPassword(String password) {
    final String hashedPassword = _hashPassword(password, salt!);
    print("hashed: " + hashedPassword);
    return hashedPassword == passwordHash;
  }

  // Nouvelle méthode interne pour hacher le mot de passe
  String _hashPassword(String password, String salt) {
    final String combined = '$password$salt';
    final List<int> bytes = utf8.encode(combined);
    final Digest hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }

  static Compte fromJson(Map<String, dynamic> json) => _$CompteFromJson(json);

  Map<String, dynamic> toJson() => _$CompteToJson(this);

  @override
  List<Object?> get props =>
      [id, email, passwordHash, salt, entrainements, equides];

  Compte copyWith(
      {String? id,
      String? email,
      String? nom,
      String? prenom,
      String? passwordHash,
      String? salt,
      List<Evenement>? evenements,
      List<Equide>? equides,
      List<Entrainement>? entrainements}) {
    return Compte(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      equides: equides ?? this.equides,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      evenements: evenements ?? this.evenements,
      entrainements: entrainements ?? this.entrainements,
    );
  }
}
