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

class ReportsState extends Equatable {
  const ReportsState({
    this.tarkastelupvm = '',
    this.kunta = '0',
    this.huoneistomaara = 0,
    this.taajama = 0,
    this.kohdeTyyppi = 0,
    this.onkoViemari = 0,
    this.runStatus = ReportsRunStatus.idle,
    this.currentTaskId,
    this.currentDescription,
    this.statusMessage,
    this.errorMessage,
    this.resultFileName,
    this.resultUrl,
    this.sharepointError,
    this.cancelRequested = false,
  });

  final String tarkastelupvm;
  final String kunta;
  final int huoneistomaara;
  final int taajama;
  final int kohdeTyyppi;
  final int onkoViemari;
  final ReportsRunStatus runStatus;
  final String? currentTaskId;
  final String? currentDescription;
  final String? statusMessage;
  final String? errorMessage;
  final String? resultFileName;
  final String? resultUrl;
  final String? sharepointError;
  final bool cancelRequested;

  bool get isBusy =>
      runStatus == ReportsRunStatus.submitting ||
      runStatus == ReportsRunStatus.running ||
      runStatus == ReportsRunStatus.cancelling;

  ReportsState copyWith({
    String? tarkastelupvm,
    String? kunta,
    int? huoneistomaara,
    int? taajama,
    int? kohdeTyyppi,
    int? onkoViemari,
    ReportsRunStatus? runStatus,
    Object? currentTaskId = _unset,
    Object? currentDescription = _unset,
    Object? statusMessage = _unset,
    Object? errorMessage = _unset,
    Object? resultFileName = _unset,
    Object? resultUrl = _unset,
    Object? sharepointError = _unset,
    bool? cancelRequested,
    bool clearTransient = false,
  }) {
    return ReportsState(
      tarkastelupvm: tarkastelupvm ?? this.tarkastelupvm,
      kunta: kunta ?? this.kunta,
      huoneistomaara: huoneistomaara ?? this.huoneistomaara,
      taajama: taajama ?? this.taajama,
      kohdeTyyppi: kohdeTyyppi ?? this.kohdeTyyppi,
      onkoViemari: onkoViemari ?? this.onkoViemari,
      runStatus: runStatus ?? this.runStatus,
        currentTaskId: clearTransient
          ? null
          : currentTaskId == _unset
            ? this.currentTaskId
            : currentTaskId as String?,
        currentDescription: clearTransient
          ? null
          : currentDescription == _unset
            ? this.currentDescription
            : currentDescription as String?,
        statusMessage: clearTransient
          ? null
          : statusMessage == _unset
            ? this.statusMessage
            : statusMessage as String?,
        errorMessage: clearTransient
          ? null
          : errorMessage == _unset
            ? this.errorMessage
            : errorMessage as String?,
        resultFileName: clearTransient
          ? null
          : resultFileName == _unset
            ? this.resultFileName
            : resultFileName as String?,
        resultUrl: clearTransient
          ? null
          : resultUrl == _unset
            ? this.resultUrl
            : resultUrl as String?,
        sharepointError: clearTransient
          ? null
          : sharepointError == _unset
            ? this.sharepointError
            : sharepointError as String?,
      cancelRequested: clearTransient ? false : cancelRequested ?? this.cancelRequested,
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
        runStatus,
        currentTaskId,
        currentDescription,
        statusMessage,
        errorMessage,
        resultFileName,
        resultUrl,
        sharepointError,
        cancelRequested,
      ];
}