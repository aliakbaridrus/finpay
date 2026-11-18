# AGENTS.md — Arsitektur & Standar Penulisan Kode FinPay

Dokumen ini merupakan acuan arsitektur perangkat lunak, standar kode, dan pola pengembangan untuk proyek **FinPay** (Aplikasi Dompet Digital, Pembayaran QRIS, & Layanan Keuangan). Gunakan panduan ini sebagai standar wajib saat membuat fitur baru atau memodifikasi fitur yang ada.

---

## 1. Tech Stack, Framework, & Library

- **Framework & SDK**:
  - **Flutter** (Material 3 / `useMaterial3: true`)
  - **Dart SDK**: `>=3.3.0 <4.0.0` (memanfaatkan fitur modern Dart 3 seperti *class modifiers* `abstract final class`, *pattern matching / switch expressions*, dan *named records* `({Type a, Type b})`).
- **Dependencies Utama** (`pubspec.yaml`):
  - `google_fonts: ^6.3.3` — Tipografi utama berbasis font **Plus Jakarta Sans**.
  - `qr_flutter: ^4.1.0` — Rendering QR Code standar EMVCo QRIS.
- **Linter & Static Analysis** (`analysis_options.yaml`):
  - `flutter_lints: ^4.0.0` dengan aturan ketat:
    - `prefer_const_constructors: true`
    - `prefer_const_literals_to_create_immutables: true`
    - `prefer_single_quotes: true`
- **Integrasi Eksternal & Jaringan (Zero Extra Dependency)**:
  - **Firebase Cloud Firestore REST API**: Sinkronisasi koleksi (`wallets`, `transactions`, `midtrans_orders`, `support_chats`) menggunakan `dart:io` (`HttpClient`) dan `dart:convert` tanpa ketergantungan plugin native berat.
  - **Midtrans Sandbox API**: Pembuatan Snap Token (`POST /snap/v1/transactions`) dan pengecekan status pembayaran (`GET /v2/{orderId}/status`) dengan fallback simulator lokal otomatis.
  - **Standar EMVCo QRIS**: Parser, generator payload TLV (*Tag-Length-Value*), dan kalkulasi checksum `CRC16/CCITT-FALSE` mandiri di `qris_model.dart`.

---

## 2. Arsitektur & Struktur Direktori

Proyek menggunakan pendekatan **Feature-First dikombinasikan dengan Layer-Based Core/Data/Shared** di dalam `lib/`:

```text
lib/
├── main.dart                  # Entry point, konfigurasi SystemChrome, MaterialApp, & routing utama ('/' & '/admin')
├── core/                      # Layer fundamental & utilitas global (tidak bergantung pada fitur)
│   ├── theme/                 # Design system tokens (AppColors, AppSpacing, AppRadius, AppSizes, AppShadows, AppTextStyles, AppTheme)
│   └── utils/                 # Helper murni tanpa state (contoh: CurrencyFormatter)
├── data/                      # Layer data, domain model, state in-memory, & service backend
│   ├── dummy/                 # Sumber data lokal / in-memory store (DummyData)
│   ├── models/                # Immutable data models, serialisasi Firestore & parser QRIS
│   └── services/              # Singleton services (WalletService, TransactionService, QrisService, MidtransService, SupportChatService)
├── features/                  # Modul fitur mandiri berbasis halaman/tab
│   ├── main/                  # Shell navigasi utama (IndexedStack + FinPayBottomNavBar)
│   ├── home/                  # Tab Beranda & widget spesifik beranda
│   ├── history/               # Tab Riwayat Transaksi, filter, & e-statement
│   ├── pay/                   # Tab Scan QRIS, QRIS Saya, & Tarik Tunai
│   ├── finance/               # Tab Portofolio Keuangan, kesehatan finansial, & target menabung
│   ├── account/               # Tab Akun, pengaturan keamanan, KYC, & sub-halaman profil
│   ├── services/              # Halaman penuh layanan finansial (Top Up, Transfer, Tabungan, Pinjaman, Cash Flow, Promo)
│   └── admin/                 # Portal Web Admin Dashboard ('/admin')
└── shared/                    # Komponen UI lintas fitur
    ├── dialogs/               # Modal bottom sheets aksi finansial & dialog struk transaksi (FinPayReceiptDialog)
    └── widgets/               # Atomic/reusable widgets (AppCard, IconBox, MenuGrid, PillBadge, QrisCodeCard, dll.)
```

### Aturan Batasan Layer (Layer Boundaries)
1. **`core/`** tidak boleh mengimpor apa pun dari `data/`, `features/`, atau `shared/`.
2. **`data/`** hanya boleh mengimpor dari `core/` (mis. `AppColors` untuk warna badge default). `data/services/` tidak boleh memegang referensi `BuildContext`.
3. **`shared/`** berisi komponen UI generik atau dialog transaksi yang dipakai oleh lebih dari satu fitur.
4. **`features/`** mengonsumsi `core/`, `data/`, dan `shared/`. Widget yang hanya dipakai di satu fitur wajib ditempatkan di `features/<nama_fitur>/widgets/`.

---

## 3. Standar Penulisan Kode (Coding Conventions)

### A. Penamaan (Naming Conventions)
- **File & Folder**: `snake_case.dart` (contoh: `wallet_service.dart`, `qris_confirm_sheet.dart`).
- **Kelas, Enum, & Typedef**: `PascalCase` dengan sufiks sesuai peran:
  - Model: `*Model` / `*Data` / `*Payload` (contoh: `TransactionModel`, `WalletModel`, `QrisPayload`).
  - Service: `*Service` (contoh: `WalletService`, `TransactionService`).
  - Halaman utama/sub-halaman: `*Page` (contoh: `HomePage`, `TransferPage`).
  - Bottom sheet: `*Sheet` (contoh: `TransferActionSheet`, `QrisConfirmSheet`).
  - Helper navigasi: `*NavigationHelper` (contoh: `ServiceNavigationHelper`).
- **Variabel, Fungsi, & Parameter**: `camelCase`. Anggota privat diawali underscore (`_selectedFilter`, `_syncWalletToFirestore`).
- **Namespace Konstanta**: Gunakan `abstract final class` dengan properti `static const` (contoh: `AppColors`, `AppSpacing`, `AppRadius`, `AppSizes`, `CurrencyFormatter`).

### B. Gaya Bahasa & Kutipan
- **Single Quotes**: Wajib menggunakan kutipan tunggal (`'...'`) untuk semua string sesuai aturan linter.
- **Immutability & `const`**:
  - Semua field pada Model dan Widget harus `final`.
  - Selalu gunakan `const` pada konstruktor widget dan deklarasi list/elemen statis.
- **Bahasa Komentar & UI**:
  - Teks antarmuka pengguna (UI), pesan error ke pengguna, dan komentar dokumentasi (`///`) ditulis dalam **Bahasa Indonesia** yang jelas dan ringkas.
  - Identifier kode (nama class, method, variabel) ditulis dalam **Bahasa Inggris** (kecuali method domain spesifik seperti `CurrencyFormatter.rupiah`).

### C. Struktur Fungsi & Pemisahan Widget
- **Signature Fungsi**: Gunakan *named parameters* (`{required this.a, this.b}`) untuk konstruktor widget, model, dan method service yang memiliki lebih dari 1 parameter.
- **Multiple Return Values**: Gunakan **Dart 3 Named Records** untuk fungsi yang mengembalikan lebih dari satu nilai (contoh: `Future<({TransactionModel transaction, int monthlyInstallment})> disburseLoan(...)`).
- **Widget Decomposition**:
  - Utamakan membuat *private StatelessWidget* (`class _FilterChip extends StatelessWidget`) di bagian bawah file dibandingkan helper method pembuat widget yang panjang, agar Flutter dapat mengoptimalkan rebuild.
  - Helper method `_build*()` hanya digunakan di dalam `State` jika bergantung langsung pada state internal halaman tersebut.

---

## 4. Manajemen State & Alur Data

Proyek ini **tidak menggunakan package state management eksternal** (seperti Bloc, Provider, atau Riverpod), melainkan mengandalkan arsitektur reaktif bawaan Flutter:

1. **Singleton Service + `ValueNotifier`**:
   - Setiap service dideklarasikan sebagai singleton dengan konstruktor privat:
     ```dart
     class WalletService {
       WalletService._();
       static final WalletService instance = WalletService._();
       final ValueNotifier<WalletModel> walletNotifier = ValueNotifier<WalletModel>(...);
     }
     ```
   - UI mendengarkan perubahan state global menggunakan `ValueListenableBuilder<T>` (contoh: memantau `walletNotifier`, `transactionsNotifier`, atau `messagesNotifier`).
2. **In-Memory Store & Offline-First Sync**:
   - `DummyData` berfungsi sebagai *in-memory single source of truth* agar mutasi saldo dan transaksi langsung terasa instan di seluruh halaman.
   - Setiap mutasi di service wajib:
     1. Memvalidasi input terlebih dahulu.
     2. Memperbarui state lokal (`DummyData`) dan memicu `notifier.value = ...` (dengan membuat instance atau `List.from(...)` baru agar listener terpicu).
     3. Menyinkronkan data ke Firebase Firestore secara asinkron di latar belakang.
3. **Ephemeral UI State**:
   - State lokal halaman (seperti tab aktif, filter chip, input form, status `_isProcessing`, toggle visibilitas) dikelola menggunakan `StatefulWidget` dan `setState()`.
   - Semua `TextEditingController` dan `AnimationController` **wajib** di-`dispose()` pada lifecycle `dispose()`.

---

## 5. Penanganan Error (Error Handling)

1. **Validasi Bisnis & Domain Exceptions**:
   - Gunakan custom exception bertipe jelas untuk domain kompleks (contoh: `class QrisFormatException implements Exception` untuk validasi format, panjang TLV, atau checksum CRC16 QRIS).
   - Untuk validasi transaksi di `WalletService` (saldo tidak cukup, nominal `<= 0`, order duplikat), lempar `Exception('Pesan error dalam Bahasa Indonesia')`.
2. **Graceful Degradation pada Jaringan (Offline-Safe)**:
   - Panggilan HTTP ke Firebase Firestore dan Midtrans Sandbox wajib memiliki `connectionTimeout` (5–6 detik) dan dibungkus `try / catch (_)`.
   - Kegagalan jaringan pada sinkronisasi background **tidak boleh menghentikan alur aplikasi**; gunakan fallback state lokal atau simulator sandbox agar fitur tetap berjalan mulus saat offline maupun saat unit testing.
3. **Penanganan Error di Layer UI**:
   - Bungkus pemanggilan async service di UI dengan `try / on CustomException catch (e) / catch (e)`.
   - Selalu periksa `if (!mounted) return;` (atau `if (!context.mounted) return;`) setelah setiap `await` sebelum memanggil `setState`, `Navigator`, atau `ScaffoldMessenger`.
   - Tampilkan pesan error yang bersih ke pengguna menggunakan `SnackBar`:
     ```dart
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
     );
     ```

---

## 6. Standar UI/UX, Layout, & Navigasi

- **Design Tokens Wajib**:
  - Jangan melakukan *hardcode* warna, ukuran font, atau radius bila sudah tersedia di `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppSizes`, dan `AppShadows`.
  - Gunakan `.withValues(alpha: ...)` (standar Flutter terbaru) alih-alih `.withOpacity(...)` yang sudah deprecated.
- **Format Mata Uang & Nomor Referensi**:
  - Selalu format nilai uang dengan `CurrencyFormatter.rupiah(nominal, withSign: ...)` — jangan memformat string `"Rp ..."` secara manual.
  - Nomor referensi transaksi menggunakan format `FPX-...` (mis. `FPX-QR...` untuk QRIS, `FPX-SV...` untuk Tabungan, `FPX-LN...` untuk Pinjaman).
- **Responsive Mobile Constraint**:
  - Seluruh halaman mobile harus dibungkus dengan `Center` + `ConstrainedBox(constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth))` (`480px`) agar tampilan tetap proporsional saat dijalankan di Web atau Tablet.
  - Gunakan `SubPageScaffold` untuk sub-halaman agar header, tombol kembali, dan batas lebar konsisten.
- **Pola Navigasi**:
  - Navigasi antar layanan menggunakan `ServiceNavigationHelper` atau `AccountNavigationHelper` (dengan transisi `SlideTransition` + `FadeTransition` berdurasi `320ms`), atau melalui modal bottom sheet terpusat di `FinancialActionSheets`.
  - Setiap aksi transaksi finansial yang sukses wajib menampilkan struk digital (`showFinPayReceiptDialog` atau `showQrisReceipt`).

---

## 7. Standar Pengujian (Testing)

- Setiap penambahan logika bisnis di `data/models/` atau `data/services/` harus disertai unit test di folder `test/`.
- Saat menulis unit test untuk service yang terhubung ke Firestore (seperti pada `test/wallet_service_test.dart`):
  - Kosongkan `FirebaseFirestoreConfig.projectId = ''` di dalam `setUp()` untuk menonaktifkan panggilan jaringan selama tes.
  - Kembalikan nilai saldo `DummyData` dan `projectId` ke kondisi semula di dalam `tearDown()`.
