class DbColumnDoc {
  final String skeema;
  final String taulu;
  final String kentta;
  final String? tyyppi;
  final String? taulunKommentti;
  final String? kentanKommentti;
  final String? isNullable;
  final int? dimensions;
  final String? coordinateSystem;

  const DbColumnDoc({
    required this.skeema,
    required this.taulu,
    required this.kentta,
    this.tyyppi,
    this.taulunKommentti,
    this.kentanKommentti,
    this.isNullable,
    this.dimensions,
    this.coordinateSystem,
  });

  factory DbColumnDoc.fromJson(Map<String, dynamic> json) {
    return DbColumnDoc(
      skeema: json['skeema'] as String? ?? '',
      taulu: json['taulu'] as String? ?? '',
      kentta: json['kentta'] as String? ?? '',
      tyyppi: json['tyyppi'] as String?,
      taulunKommentti: json['taulun_kommentti'] as String?,
      kentanKommentti: json['kentan_kommentti'] as String?,
      isNullable: json['is_nullable'] as String?,
      dimensions: json['dimensions'] as int?,
      coordinateSystem: json['coordinate_system']?.toString(),
    );
  }

  bool get isNotNull => (isNullable ?? '').toUpperCase() != 'YES';

  String? get geometryInfo {
    if (dimensions == null) return null;
    final geo = '${tyyppi ?? ''} ${dimensions}D';
    if (coordinateSystem != null) return '$geo SRID:$coordinateSystem';
    return geo;
  }
}

class SchemaDoc {
  final String name;
  final Map<String, TableDoc> tables;

  const SchemaDoc({required this.name, required this.tables});
}

class TableDoc {
  final String name;
  final String? comment;
  final List<DbColumnDoc> columns;

  const TableDoc({required this.name, this.comment, required this.columns});
}
