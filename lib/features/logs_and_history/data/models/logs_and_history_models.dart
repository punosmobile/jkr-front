class LogOverview {
  const LogOverview({
    required this.velvoitetarkistusAjettu,
    required this.viimeisinRaporttiGeneroitu,
    required this.uusinPaatosKannassa,
    required this.uusinKompostointiIlmoitus,
    required this.lietekuljetusViimeisinTyhjennys,
    required this.kiinteaKuljetusViimeisinKvartaali,
    required this.viimeisinTuonti,
    required this.viimeisimmatJarjestelmatapahtumat,
  });

  final LogSummaryItem velvoitetarkistusAjettu;
  final LogSummaryItem viimeisinRaporttiGeneroitu;
  final LogSummaryItem uusinPaatosKannassa;
  final LogSummaryItem uusinKompostointiIlmoitus;
  final LogSummaryItem lietekuljetusViimeisinTyhjennys;
  final LogSummaryItem kiinteaKuljetusViimeisinKvartaali;
  final LogSummaryItem viimeisinTuonti;
  final List<LogEventItem> viimeisimmatJarjestelmatapahtumat;

  factory LogOverview.fromJson(Map<String, dynamic> json) {
    return LogOverview(
      velvoitetarkistusAjettu: LogSummaryItem.fromJson(
        json['velvoitetarkistus_ajettu'] as Map<String, dynamic>? ?? const {},
      ),
      viimeisinRaporttiGeneroitu: LogSummaryItem.fromJson(
        json['viimeisin_raportti_generoitu'] as Map<String, dynamic>? ?? const {},
      ),
      uusinPaatosKannassa: LogSummaryItem.fromJson(
        json['uusin_paatos_kannassa'] as Map<String, dynamic>? ?? const {},
      ),
      uusinKompostointiIlmoitus: LogSummaryItem.fromJson(
        json['uusin_kompostointi_ilmoitus'] as Map<String, dynamic>? ?? const {},
      ),
      lietekuljetusViimeisinTyhjennys: LogSummaryItem.fromJson(
        json['lietekuljetus_viimeisin_tyhjennys'] as Map<String, dynamic>? ?? const {},
      ),
      kiinteaKuljetusViimeisinKvartaali: LogSummaryItem.fromJson(
        json['kiintea_kuljetus_viimeisin_kvartaali'] as Map<String, dynamic>? ?? const {},
      ),
      viimeisinTuonti: LogSummaryItem.fromJson(
        json['viimeisin_tuonti'] as Map<String, dynamic>? ?? const {},
      ),
      viimeisimmatJarjestelmatapahtumat:
          (json['viimeisimmat_jarjestelmatapahtumat'] as List<dynamic>? ?? const [])
              .map((item) => LogEventItem.fromJson(item as Map<String, dynamic>))
              .toList(growable: false),
    );
  }
}

class LogSummaryItem {
  const LogSummaryItem({
    this.occurredAt,
    this.status,
    this.detail,
    this.runner,
  });

  final DateTime? occurredAt;
  final String? status;
  final String? detail;
  final String? runner;

  factory LogSummaryItem.fromJson(Map<String, dynamic> json) {
    return LogSummaryItem(
      occurredAt: _parseDateTime(json['occurred_at']),
      status: json['status'] as String?,
      detail: json['detail'] as String?,
      runner: json['runner'] as String?,
    );
  }
}

class LogEventItem {
  const LogEventItem({
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

  factory LogEventItem.fromJson(Map<String, dynamic> json) {
    return LogEventItem(
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

class LogHistoryImportLogItem {
  const LogHistoryImportLogItem({
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

  factory LogHistoryImportLogItem.fromJson(Map<String, dynamic> json) {
    return LogHistoryImportLogItem(
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