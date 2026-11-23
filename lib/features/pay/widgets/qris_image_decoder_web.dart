// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

/// Membuka pemilih file gambar di browser lalu men-decode barcode QRIS di dalamnya.
Future<String?> pickAndDecodePlatformQrisImage() async {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final file = files.first;
    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      final dataUrl = reader.result?.toString() ?? '';
      if (dataUrl.isEmpty) {
        if (!completer.isCompleted) completer.complete('');
        return;
      }

      var holder = html.document.getElementById('finpay-qr-image-holder');
      if (holder == null) {
        holder = html.DivElement()
          ..id = 'finpay-qr-image-holder'
          ..style.display = 'none';
        html.document.body?.append(holder);
      }
      holder.setAttribute('data-url', dataUrl);
      holder.setAttribute('data-result', '');

      late StreamSubscription<html.Event> sub;
      sub = html.window.on['finpay-image-qr-decoded'].listen((_) {
        sub.cancel();
        final decoded = (holder?.getAttribute('data-result') ?? '').trim();
        if (!completer.isCompleted) {
          completer.complete(decoded);
        }
      });

      html.window.dispatchEvent(
        html.CustomEvent('finpay-decode-image-request'),
      );
    });
    reader.readAsDataUrl(file);
  });

  input.click();
  return completer.future.timeout(
    const Duration(seconds: 45),
    onTimeout: () => null,
  );
}
