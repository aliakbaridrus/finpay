/// Satu bagian dokumen hukum: judul + isi.
class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// Isi dummy untuk Syarat & Ketentuan dan Kebijakan Privasi.
/// Ganti dengan teks resmi jika aplikasi dirilis sungguhan.
abstract final class AccountLegal {
  static const String updatedAt = 'Oktober 2026';

  static const List<LegalSection> terms = [
    LegalSection(
      'Ketentuan Umum',
      'Dengan membuat akun dan menggunakan FinPay, kamu menyetujui seluruh '
          'syarat dan ketentuan ini. Jika tidak setuju, mohon hentikan '
          'penggunaan layanan.',
    ),
    LegalSection(
      'Pendaftaran & Verifikasi Akun',
      'Pengguna wajib berusia minimal 17 tahun dan memberikan data yang '
          'benar, lengkap, dan terbaru. FinPay berhak melakukan verifikasi '
          'identitas sesuai ketentuan yang berlaku.',
    ),
    LegalSection(
      'Penggunaan Layanan',
      'Layanan FinPay hanya boleh digunakan untuk tujuan yang sah. '
          'Dilarang menggunakan layanan untuk kegiatan yang melanggar '
          'hukum, termasuk pencucian uang dan penipuan.',
    ),
    LegalSection(
      'Biaya & Limit Transaksi',
      'Biaya layanan dan limit transaksi ditampilkan sebelum transaksi '
          'dikonfirmasi. FinPay dapat menyesuaikan biaya dan limit dengan '
          'pemberitahuan terlebih dahulu.',
    ),
    LegalSection(
      'Keamanan Akun',
      'Pengguna bertanggung jawab menjaga kerahasiaan PIN, OTP, dan '
          'perangkat. Segera laporkan jika terjadi aktivitas mencurigakan '
          'atau kehilangan perangkat.',
    ),
    LegalSection(
      'Perubahan Ketentuan',
      'FinPay dapat memperbarui syarat dan ketentuan sewaktu-waktu. '
          'Perubahan penting akan diberitahukan melalui aplikasi.',
    ),
  ];

  static const List<LegalSection> privacy = [
    LegalSection(
      'Data yang Kami Kumpulkan',
      'Kami mengumpulkan data identitas (nama, NIK, foto KTP dan selfie), '
          'data kontak, data perangkat, serta riwayat transaksi yang kamu '
          'lakukan di FinPay.',
    ),
    LegalSection(
      'Penggunaan Data',
      'Data digunakan untuk memverifikasi identitas, memproses transaksi, '
          'mencegah penipuan, meningkatkan layanan, dan memenuhi kewajiban '
          'hukum.',
    ),
    LegalSection(
      'Berbagi Data',
      'Kami tidak menjual data pribadimu. Data hanya dibagikan kepada '
          'mitra yang diperlukan untuk layanan (mis. bank) atau otoritas '
          'yang berwenang sesuai peraturan.',
    ),
    LegalSection(
      'Penyimpanan & Keamanan',
      'Data disimpan dengan enkripsi dan akses terbatas. Meski begitu, '
          'tidak ada sistem yang sepenuhnya kebal, jadi jaga juga '
          'keamanan perangkatmu.',
    ),
    LegalSection(
      'Hak Pengguna',
      'Kamu berhak mengakses, memperbarui, dan meminta penghapusan data '
          'pribadi sesuai ketentuan perundang-undangan yang berlaku.',
    ),
    LegalSection(
      'Kontak',
      'Pertanyaan seputar privasi dapat disampaikan melalui menu Hubungi '
          'CS di aplikasi FinPay.',
    ),
  ];
}
