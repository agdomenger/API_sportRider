// ignore_for_file: prefer_const_constructors
import '../../../in_memory_comptes_data_source/lib/in_memory_comptes_data_source.dart';
import 'package:test/test.dart';

void main() {
  group('ComptesDataSource', () {
    test('can be instantiated', () {
      expect(InMemoryComptesDataSource(), isNotNull);
    });
  });
}
