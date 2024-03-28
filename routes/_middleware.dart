import 'package:comptes_data_source/comptes_data_source.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:firedart/firedart.dart';
import 'package:in_memory_comptes_data_source/in_memory_comptes_data_source.dart';

final _dataSource = InMemoryComptesDataSource();

Handler middleware(Handler handler) {
  final firestoreInitializer = Firestore.initialize('data-5b679');

  return handler
      .use(requestLogger())
      .use(provider<ComptesDataSource>((_) => _dataSource));
}
