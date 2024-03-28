// ignore_for_file: prefer_const_constructors
import 'package:in_memory_comptes_data_source/in_memory_comptes_data_source.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryComptesDataSource', () {
    test('can be instantiated', () {
      expect(InMemoryComptesDataSource(), isNotNull);
    });
  });
}
