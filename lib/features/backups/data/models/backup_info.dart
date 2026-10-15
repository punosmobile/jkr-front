import 'package:equatable/equatable.dart';

/// Yhden varmuuskopiotiedoston tiedot (GET /db/dumps).
class BackupInfo extends Equatable {
  const BackupInfo({
    required this.filename,
    required this.size,
    required this.createdAt,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      filename: json['filename'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String filename;
  final int size;
  final DateTime createdAt;

  /// Ihmisluettava kokomerkkijono (esim. "412 Mt").
  String get formattedSize {
    const kilo = 1024;
    if (size < kilo) {
      return '$size t';
    }
    final kt = size / kilo;
    if (kt < kilo) {
      return '${kt.toStringAsFixed(kt < 10 ? 1 : 0)} kt';
    }
    final mt = kt / kilo;
    if (mt < kilo) {
      return '${mt.toStringAsFixed(mt < 10 ? 1 : 0)} Mt';
    }
    final gt = mt / kilo;
    return '${gt.toStringAsFixed(gt < 10 ? 2 : 1)} Gt';
  }

  @override
  List<Object?> get props => [filename, size, createdAt];
}
