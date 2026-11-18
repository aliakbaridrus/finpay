import 'dart:convert';
import 'dart:typed_data';

import '../../data/models/transaction_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/wealth_models.dart';
import 'currency_formatter.dart';
import 'pdf_downloader_stub.dart'
    if (dart.library.html) 'pdf_downloader_web.dart'
    if (dart.library.io) 'pdf_downloader_io.dart' as downloader;

/// Generator dokumen e-Statement berformat standar `%PDF-1.4` murni
/// beserta trigger unduhan file `.pdf` ke perangkat (Web & Desktop/Mobile).
abstract final class PdfStatementGenerator {
  /// Menghasilkan bytes file `.pdf` untuk laporan e-Statement FinPay.
  static Uint8List generatePdfBytes({
    required UserProfileModel user,
    required CashFlowSummaryModel summary,
    required List<TransactionModel> transactions,
    required String periodLabel,
    required String generatedDateLabel,
  }) {
    final lines = <String>[
      'FINPAY DIGITAL WALLET - E-STATEMENT RESMI (.PDF)',
      'Terdaftar & Diawasi OJK - Laporan Mutasi & Arus Kas',
      '========================================================================',
      'Nama Pemilik Akun : ${_sanitize(user.fullName)}',
      'Email / No. HP    : ${_sanitize(user.email)} / ${_sanitize(user.phoneNumber)}',
      'NIK KTP           : ${_sanitize(user.nik)}',
      'Rentang Periode   : ${_sanitize(periodLabel)}',
      'Tanggal Cetak     : ${_sanitize(generatedDateLabel)}',
      '========================================================================',
      'RINGKASAN ARUS KAS (CASH FLOW)',
      '------------------------------------------------------------------------',
      'Total Pemasukan           : ${CurrencyFormatter.rupiah(summary.totalIncome)}',
      'Total Pengeluaran         : ${CurrencyFormatter.rupiah(summary.totalExpense)}',
      'Alokasi Tabungan Impian   : ${CurrencyFormatter.rupiah(summary.totalSaving)}',
      'Perubahan Saldo Bersih    : ${CurrencyFormatter.rupiah(summary.netSurplus, withSign: true)}',
      'Skor Kesehatan Finansial  : ${summary.financialHealthScore}/100 (${_sanitize(summary.healthStatusLabel)})',
      '========================================================================',
      'RINCIAN MUTASI TRANSAKSI (${transactions.length} Transaksi)',
      '------------------------------------------------------------------------',
    ];

    if (transactions.isEmpty) {
      lines.add('Belum ada transaksi uang masuk atau keluar pada periode ini.');
    } else {
      for (var i = 0; i < transactions.length && i < 24; i++) {
        final trx = transactions[i];
        final amt = CurrencyFormatter.rupiah(trx.amount, withSign: true);
        final title = _sanitize(trx.title);
        final date = _sanitize(trx.dateTime);
        final ref = _sanitize(trx.referenceNumber);
        lines.add('${(i + 1).toString().padLeft(2, '0')}. [$date] $title');
        lines.add('    Ref: $ref | Kanal: ${_sanitize(trx.channel)} | Nominal: $amt');
      }
    }

    lines.add('========================================================================');
    lines.add('Dokumen ini diterbitkan secara elektronik oleh sistem FinPay.');

    // Bangun stream konten teks PDF (Font Courier/Helvetica standar PDF 1.4)
    final contentBuffer = StringBuffer()
      ..writeln('BT')
      ..writeln('/F1 9 Tf')
      ..writeln('40 790 Td')
      ..writeln('13 TL');

    for (final line in lines) {
      final escaped = line
          .replaceAll(r'\', r'\\')
          .replaceAll('(', r'\(')
          .replaceAll(')', r'\)');
      contentBuffer.writeln('($escaped) Tj T*');
    }
    contentBuffer.writeln('ET');
    final streamContent = contentBuffer.toString();

    final objects = <String>[
      '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n',
      '2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n',
      '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>\nendobj\n',
      '4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>\nendobj\n',
      '5 0 obj\n<< /Length ${streamContent.length} >>\nstream\n$streamContent\nendstream\nendobj\n',
    ];

    final pdfBuffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[];

    for (final obj in objects) {
      offsets.add(pdfBuffer.toString().length);
      pdfBuffer.write(obj);
    }

    final xrefOffset = pdfBuffer.toString().length;
    pdfBuffer.writeln('xref');
    pdfBuffer.writeln('0 ${objects.length + 1}');
    pdfBuffer.writeln('0000000000 65535 f ');
    for (final offset in offsets) {
      pdfBuffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
    }
    pdfBuffer.writeln('trailer');
    pdfBuffer.writeln('<< /Size ${objects.length + 1} /Root 1 0 R >>');
    pdfBuffer.writeln('startxref');
    pdfBuffer.writeln('$xrefOffset');
    pdfBuffer.write('%%EOF');

    return Uint8List.fromList(latin1.encode(pdfBuffer.toString()));
  }

  /// Mengunduh file `.pdf` ke perangkat pengguna dan mengembalikan informasi lokasi/nama file.
  static Future<String> downloadPdfFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final cleanFileName =
        fileName.toLowerCase().endsWith('.pdf') ? fileName : '$fileName.pdf';
    return downloader.savePdfToDevice(cleanFileName, bytes);
  }

  static String _sanitize(String input) {
    // Hanya pertahankan karakter ASCII yang didukung font standar PDF Type1
    return input.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
  }
}
