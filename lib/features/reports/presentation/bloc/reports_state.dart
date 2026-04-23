import 'package:equatable/equatable.dart';

enum ReportsRunStatus {
  idle,
  submitting,
  running,
  cancelling,
  completed,
  failed,
}

const _unset = Object();

class ReportRunParameters extends Equatable {
  const ReportRunParameters({
    required this.tarkastelupvm,
    required this.kunta,
    required this.huoneistomaara,
    required this.taajama,
    required this.kohdeTyyppi,
    required this.onkoViemari,
  });

  final String tarkastelupvm;
  final String kunta;
  final int huoneistomaara;
  final int taajama;
  final int kohdeTyyppi;
  final int onkoViemari;

  Map<String, dynamic> toJson() {
    return {
      'tarkastelupvm': tarkastelupvm,
      'kunta': kunta,
      'huoneistomaara': huoneistomaara,
      'taajama': taajama,
      'kohdeTyyppi': kohdeTyyppi,
      'onkoViemari': onkoViemari,
    };
  }

  factory ReportRunParameters.fromJson(Map<String, dynamic> json) {
    return ReportRunParameters(
      tarkastelupvm: json['tarkastelupvm'] as String? ?? '',
      kunta: json['kunta'] as String? ?? '0',
      huoneistomaara: (json['huoneistomaara'] as num?)?.toInt() ?? 0,
      taajama: (json['taajama'] as num?)?.toInt() ?? 0,
      kohdeTyyppi: (json['kohdeTyyppi'] as num?)?.toInt() ?? 0,
      onkoViemari: (json['onkoViemari'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        tarkastelupvm,
        kunta,
        huoneistomaara,
        taajama,
        kohdeTyyppi,
        onkoViemari,
      ];
}

class ReportRunState extends Equatable {
  const ReportRunState({
    required this.id,
    this.taskId,
    this.description,
    this.parameters,
    required this.runStatus,
    this.statusMessage,
    this.errorMessage,
    this.resultFileName,
    this.resultUrl,
    this.sharepointError,
    this.cancelRequested = false,
    this.isCollapsed = false,
    this.lastUpdatedAt,
  });

  final String id;
  final String? taskId;
  final String? description;
  final ReportRunParameters? parameters;
  final ReportsRunStatus runStatus;
  final String? statusMessage;
  final String? errorMessage;
  final String? resultFileName;
  final String? resultUrl;
  final String? sharepointError;
  final bool cancelRequested;
  final bool isCollapsed;
  final DateTime? lastUpdatedAt;

  bool get isActive =>
      runStatus == ReportsRunStatus.submitting ||
      runStatus == ReportsRunStatus.running ||
      runStatus == ReportsRunStatus.cancelling;

  bool get hasResultUrl => resultUrl != null && resultUrl!.isNotEmpty;

  bool get isWaitingForResultUrl =>
      runStatus == ReportsRunStatus.completed && !hasResultUrl;

  bool get shouldPoll => isActive || isWaitingForResultUrl;

  ReportRunState copyWith({
    String? id,
    Object? taskId = _unset,
    Object? description = _unset,
    Object? parameters = _unset,
    ReportsRunStatus? runStatus,
    Object? statusMessage = _unset,
    Object? errorMessage = _unset,
    Object? resultFileName = _unset,
    Object? resultUrl = _unset,
    Object? sharepointError = _unset,
    bool? cancelRequested,
    bool? isCollapsed,
    Object? lastUpdatedAt = _unset,
  }) {
    return ReportRunState(
      id: id ?? this.id,
      taskId: taskId == _unset ? this.taskId : taskId as String?,
      description: description == _unset ? this.description : description as String?,
      parameters: parameters == _unset
          ? this.parameters
          : parameters as ReportRunParameters?,
      runStatus: runStatus ?? this.runStatus,
      statusMessage: statusMessage == _unset
          ? this.statusMessage
          : statusMessage as String?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      resultFileName: resultFileName == _unset
          ? this.resultFileName
          : resultFileName as String?,
      resultUrl: resultUrl == _unset ? this.resultUrl : resultUrl as String?,
      sharepointError: sharepointError == _unset
          ? this.sharepointError
          : sharepointError as String?,
      cancelRequested: cancelRequested ?? this.cancelRequested,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      lastUpdatedAt: lastUpdatedAt == _unset
          ? this.lastUpdatedAt
          : lastUpdatedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        description,
        parameters,
        runStatus,
        statusMessage,
        errorMessage,
        resultFileName,
        resultUrl,
        sharepointError,
        cancelRequested,
        isCollapsed,
        lastUpdatedAt,
      ];
}

class ReportsState extends Equatable {
  const ReportsState({
    this.tarkastelupvm = '',
    this.kunta = '0',
    this.huoneistomaara = 0,
    this.taajama = 0,
    this.kohdeTyyppi = 0,
    this.onkoViemari = 0,
    this.reportRuns = const [],
  });

  final String tarkastelupvm;
  final String kunta;
  final int huoneistomaara;
  final int taajama;
  final int kohdeTyyppi;
  final int onkoViemari;
  final List<ReportRunState> reportRuns;

  ReportsState copyWith({
    String? tarkastelupvm,
    String? kunta,
    int? huoneistomaara,
    int? taajama,
    int? kohdeTyyppi,
    int? onkoViemari,
    List<ReportRunState>? reportRuns,
  }) {
    return ReportsState(
      tarkastelupvm: tarkastelupvm ?? this.tarkastelupvm,
      kunta: kunta ?? this.kunta,
      huoneistomaara: huoneistomaara ?? this.huoneistomaara,
      taajama: taajama ?? this.taajama,
      kohdeTyyppi: kohdeTyyppi ?? this.kohdeTyyppi,
      onkoViemari: onkoViemari ?? this.onkoViemari,
      reportRuns: reportRuns ?? this.reportRuns,
    );
  }

  @override
  List<Object?> get props => [
        tarkastelupvm,
        kunta,
        huoneistomaara,
        taajama,
        kohdeTyyppi,
        onkoViemari,
        reportRuns,
      ];
}