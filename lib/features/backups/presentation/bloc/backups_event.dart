import 'package:equatable/equatable.dart';

// Base event type for the backups feature.
abstract class BackupsEvent extends Equatable {
  const BackupsEvent();

  @override
  List<Object?> get props => [];
}

/// Lataa varmuuskopiolistan ja palauttaa mahdolliset käynnissä olevat tehtävät.
class BackupsStarted extends BackupsEvent {
  const BackupsStarted();
}

/// Päivittää varmuuskopiolistan (vetäisy / nappi).
class BackupsRefreshed extends BackupsEvent {
  const BackupsRefreshed();
}

/// Käynnistää uuden varmuuskopion (pg_dump).
class BackupsDumpRequested extends BackupsEvent {
  const BackupsDumpRequested();
}

/// Palauttaa tietokannan valitusta varmuuskopiosta (pg_restore).
class BackupsRestoreRequested extends BackupsEvent {
  const BackupsRestoreRequested(this.filename);

  final String filename;

  @override
  List<Object?> get props => [filename];
}

/// Poistaa varmuuskopiotiedoston.
class BackupsDeleteRequested extends BackupsEvent {
  const BackupsDeleteRequested(this.filename);

  final String filename;

  @override
  List<Object?> get props => [filename];
}

/// Lataa varmuuskopion käyttäjän koneelle.
class BackupsDownloadRequested extends BackupsEvent {
  const BackupsDownloadRequested(this.filename);

  final String filename;

  @override
  List<Object?> get props => [filename];
}

/// Avaa tiedostonvalinnan ja vie valitun tiedoston palvelimelle.
class BackupsUploadRequested extends BackupsEvent {
  const BackupsUploadRequested();
}

/// Sulkee käynnissä olevan operaation tilannepalkin.
class BackupsOperationDismissed extends BackupsEvent {
  const BackupsOperationDismissed();
}

/// Sisäinen: pollaa käynnissä olevan tehtävän tilan.
class BackupsOperationPolled extends BackupsEvent {
  const BackupsOperationPolled();
}
