class DashboardOverview {
  const DashboardOverview({
    required this.velvoitetarkistusAjettu,
    required this.viimeisinRaporttiGeneroitu,
    required this.uusinPaatosKannassa,
    required this.uusinKompostointiIlmoitus,
    required this.lietekuljetusViimeisinTyhjennys,
    required this.kiinteaKuljetusViimeisinKvartaali,
    required this.viimeisinTuonti,
    required this.viimeisimmatJarjestelmatapahtumat,
  });

  final DashboardSummaryItem velvoitetarkistusAjettu;
  final DashboardSummaryItem viimeisinRaporttiGeneroitu;
  final DashboardSummaryItem uusinPaatosKannassa;
  final DashboardSummaryItem uusinKompostointiIlmoitus;
  final DashboardSummaryItem lietekuljetusViimeisinTyhjennys;
  final DashboardSummaryItem kiinteaKuljetusViimeisinKvartaali;
  final DashboardSummaryItem viimeisinTuonti;
  final List<DashboardEventItem> viimeisimmatJarjestelmatapahtumat;

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      velvoitetarkistusAjettu: DashboardSummaryItem.fromJson(
        json['velvoitetarkistus_ajettu'] as Map<String, dynamic>? ?? const {},
      ),
      viimeisinRaporttiGeneroitu: DashboardSummaryItem.fromJson(
        json['viimeisin_raportti_generoitu'] as Map<String, dynamic>? ?? const {},
      ),
      uusinPaatosKannassa: DashboardSummaryItem.fromJson(
        json['uusin_paatos_kannassa'] as Map<String, dynamic>? ?? const {},
      ),
      uusinKompostointiIlmoitus: DashboardSummaryItem.fromJson(
        json['uusin_kompostointi_ilmoitus'] as Map<String, dynamic>? ?? const {},
      ),
      lietekuljetusViimeisinTyhjennys: DashboardSummaryItem.fromJson(
        json['lietekuljetus_viimeisin_tyhjennys'] as Map<String, dynamic>? ?? const {},
      ),
      kiinteaKuljetusViimeisinKvartaali: DashboardSummaryItem.fromJson(
        json['kiintea_kuljetus_viimeisin_kvartaali'] as Map<String, dynamic>? ?? const {},
      ),
      viimeisinTuonti: DashboardSummaryItem.fromJson(
        json['viimeisin_tuonti'] as Map<String, dynamic>? ?? const {},
      ),
      viimeisimmatJarjestelmatapahtumat:
          (json['viimeisimmat_jarjestelmatapahtumat'] as List<dynamic>? ?? const [])
              .map((item) => DashboardEventItem.fromJson(item as Map<String, dynamic>))
              .toList(growable: false),
    );
  }
}

class DashboardSummaryItem {
  const DashboardSummaryItem({
    this.occurredAt,
    this.status,
    this.detail,
    this.runner,
  });

  final DateTime? occurredAt;
  final String? status;
  final String? detail;
  final String? runner;

  factory DashboardSummaryItem.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryItem(
      occurredAt: _parseDateTime(json['occurred_at']),
      status: json['status'] as String?,
      detail: json['detail'] as String?,
      runner: json['runner'] as String?,
    );
  }
}

class DashboardEventItem {
  const DashboardEventItem({
    required this.id,
    required this.title,
    required this.status,
    required this.taskType,
    this.occurredAt,
    this.detail,
    this.runner,
  });

  final String id;
  final String title;
  final String status;
  final String taskType;
  final DateTime? occurredAt;
  final String? detail;
  final String? runner;

  factory DashboardEventItem.fromJson(Map<String, dynamic> json) {
    return DashboardEventItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      taskType: json['taskType'] as String? ?? '',
      occurredAt: _parseDateTime(json['occurred_at']),
      detail: json['detail'] as String?,
      runner: json['runner'] as String?,
    );
  }
}

class DashboardImportLogItem {
  const DashboardImportLogItem({
    required this.id,
    this.paiva,
    this.kellonaika,
    this.tyyppi,
    this.status,
    this.tulos,
    this.komento,
  });

  final int id;
  final DateTime? paiva;
  final String? kellonaika;
  final String? tyyppi;
  final String? status;
  final String? tulos;
  final String? komento;

  factory DashboardImportLogItem.fromJson(Map<String, dynamic> json) {
    return DashboardImportLogItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      paiva: _parseDateTime(json['paiva']),
      kellonaika: json['kellonaika'] as String?,
      tyyppi: json['tyyppi'] as String?,
      status: json['status'] as String?,
      tulos: json['tulos'] as String?,
      komento: json['komento'] as String?,
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value)?.toLocal();
}