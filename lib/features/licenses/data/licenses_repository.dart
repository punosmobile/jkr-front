import 'package:dio/dio.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/dio_client.dart';

/// Yhden riippuvuuden lisenssitieto SBOM-listauksesta.
class LicenseDependency {
  final String name;
  final String version;
  final String license;
  final String? homepage;
  final String? author;
  final String? summary;
  final Map<String, dynamic> raw;

  const LicenseDependency({
    required this.name,
    required this.version,
    required this.license,
    this.homepage,
    this.author,
    this.summary,
    required this.raw,
  });

  factory LicenseDependency.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v) => v == null ? '' : v.toString();
    return LicenseDependency(
      name: _s(json['name'] ?? json['package'] ?? json['Name']),
      version: _s(json['version'] ?? json['Version']),
      license: _s(
        json['license'] ??
            json['License'] ??
            json['license_expression'] ??
            json['licenses'],
      ),
      homepage: (json['homepage'] ?? json['home_page'] ?? json['url']) as String?,
      author: (json['author'] ?? json['Author']) as String?,
      summary: (json['summary'] ?? json['Summary'] ?? json['description']) as String?,
      raw: json,
    );
  }
}

class LicenseSbom {
  final int count;
  final List<LicenseDependency> dependencies;
  final Map<String, dynamic> raw;

  const LicenseSbom({
    required this.count,
    required this.dependencies,
    required this.raw,
  });
}

class LicensesRepository {
  final Dio _dio = getIt<DioClient>().dio;

  /// Hakee SBOM-tyylisen lisenssilistauksen backendiltä.
  Future<LicenseSbom> fetchSbom() async {
    final response = await _dio.get('/licenses');
    final data = response.data as Map<String, dynamic>;
    final deps = (data['dependencies'] as List<dynamic>? ?? [])
        .map((e) => LicenseDependency.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = (data['count'] as num?)?.toInt() ?? deps.length;
    return LicenseSbom(count: count, dependencies: deps, raw: data);
  }

  /// Hakee yksittäisen paketin yksityiskohdat (sisältäen lisenssitekstit).
  Future<Map<String, dynamic>> fetchPackage(String name) async {
    final response = await _dio.get('/licenses/$name');
    return response.data as Map<String, dynamic>;
  }

  /// Hakee yhdistetyn NOTICE-tekstin (tekstimuoto).
  Future<String> fetchNoticesText() async {
    final response = await _dio.get(
      '/licenses',
      queryParameters: {'format': 'text'},
      options: Options(responseType: ResponseType.plain),
    );
    return response.data?.toString() ?? '';
  }
}
