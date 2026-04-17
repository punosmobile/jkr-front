import 'package:dio/dio.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../models/db_column_doc.dart';

class DocumentationRepository {
  final Dio _dio = getIt<DioClient>().dio;
  static final Options _authOptions = Options(
    extra: {AuthInterceptor.requiresAuthKey: true},
  );

  Future<List<DbColumnDoc>> fetchDocumentation() async {
    final response = await _dio.get('/db/documentation', options: _authOptions);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => DbColumnDoc.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ryhmittele rivit scheemoiksi ja tauluiksi
  static List<SchemaDoc> groupBySchema(List<DbColumnDoc> rows) {
    final Map<String, Map<String, TableDoc>> schemas = {};

    for (final row in rows) {
      schemas.putIfAbsent(row.skeema, () => {});
      final tables = schemas[row.skeema]!;
      if (!tables.containsKey(row.taulu)) {
        tables[row.taulu] = TableDoc(
          name: row.taulu,
          comment: row.taulunKommentti,
          columns: [],
        );
      }
      tables[row.taulu]!.columns.add(row);
    }

    return schemas.entries
        .map((e) => SchemaDoc(name: e.key, tables: e.value))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
