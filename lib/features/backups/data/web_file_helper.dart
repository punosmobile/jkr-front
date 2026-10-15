import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Selaimessa valittu tiedosto.
class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Web-apurit varmuuskopioiden lataamiseen ja palvelimelle vientiin.
///
/// Sovellus ajetaan vain selaimessa (Flutter web), joten `package:web`:n
/// käyttö suoraan on turvallista.
class WebFileHelper {
  const WebFileHelper._();

  /// Avaa tiedostonvalintaikkunan ja palauttaa valitun tiedoston tavut.
  /// Palauttaa `null`, jos käyttäjä ei valinnut tiedostoa.
  static Future<PickedFile?> pickFile({String accept = ''}) {
    final completer = Completer<PickedFile?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept;

    input.onchange = (web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final file = files.item(0);
      if (file == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      file.arrayBuffer().toDart.then((buffer) {
        final bytes = buffer.toDart.asUint8List();
        if (!completer.isCompleted) {
          completer.complete(PickedFile(name: file.name, bytes: bytes));
        }
      }).catchError((Object error) {
        if (!completer.isCompleted) completer.completeError(error);
      });
    }.toJS;

    input.click();
    return completer.future;
  }
}
