# AGENTS.md — Arsitektur & Standar Penulisan Kode FinPay (Audit Faktual)

Dokumen ini merupakan acuan arsitektur perangkat lunak, standar kode, dan pola pengembangan berbasis **fakta kode nyata** untuk proyek **FinPay** (`finpay/pubspec.yaml` — Aplikasi Dompet Digital, Pembayaran QRIS, & Layanan Keuangan). Gunakan panduan ini bersama dengan `.agents/rules/standar-ewallet.md` dan `.agents/skills/alur-kerja-aman/skill.md`.

---

## 1. Tech Stack, Framework, & Library (Berdasarkan `finpay/pubspec.yaml` & Kode Sumber)

- **Framework & SDK**:
  - **Flutter** dengan Material 3 (`useMaterial3: true` terbukti di `finpay/lib/core/theme/app_theme.dart`).
  - **Dart SDK**: `>=3.3.0 <4.0.0` (terbukti di `finpay/pubspec.yaml`), memanfaatkan fitur Dart 3:
    - *Class modifiers* `abstract final class` (`finpay/lib/core/theme/app_colors.dart`, `finpay/lib/core/theme/app_dimens.dart`).
    - *Switch expressions* (`finpay/lib/data/models/transaction_model.dart`, `finpay/lib/features/main/main_page.dart`).
    - *Named records* `({Type a, Type b})` (`finpay/lib/data/services/wallet_service.dart`, `finpay/lib/data/services/account_service.dart`, `finpay/lib/data/services/wealth_service.dart`).
- **Dependencies Utama** (`finpay/pubspec.yaml`):
  - `google_fonts: ^6.3.3` — Tipografi berbasis font **Plus Jakarta Sans** (`finpay/lib/core/theme/app_text_styles.dart`).
  - `http: ^1.6.0` — Klien HTTP lintas platform (Web/Chrome, Android, Desktop) untuk REST API Firebase Firestore, Firebase Auth, & Midtrans Sandbox (`finpay/lib/data/services/auth_service.dart`, `finpay/lib/data/services/account_service.dart`, `finpay/lib/data/services/wealth_service.dart`, `finpay/lib/data/services/wallet_service.dart`, `finpay/lib/data/services/transaction_service.dart`, `finpay/lib/data/services/midtrans_service.dart`, `finpay/lib/data/services/support_chat_service.dart`).
  - `qr_flutter: ^4.1.0` — Rendering QR Code standar EMVCo QRIS (`finpay/lib/shared/widgets/qris_code_card.dart`).
- **Dev Dependencies & Linter** (`finpay/pubspec.yaml` & `finpay/analysis_options.yaml`):
  - `flutter_test` (SDK) & `flutter_lints: ^4.0.0` dengan aturan aktif:
    - `prefer_const_constructors: true`
    - `prefer_const_literals_to_create_immutables: true`
    - `prefer_single_quotes: true`
- **Integrasi Eksternal & Engine Internal**:
  - **Firebase Cloud Firestore REST API**: Sinkronisasi 9 koleksi (`wallets`, `transactions`, `midtrans_orders`, `support_chats`, `users`, `linked_accounts`, `saving_goals`, `loans`, `promos`) ke endpoint `https://firestore.googleapis.com/v1/projects/finpay-app-4026a/databases/(default)/documents` (`finpay/lib/data/services/transaction_service.dart`).
  - **Firebase Auth REST API**: Login & Register Email/Password ke endpoint `identitytoolkit.googleapis.com` dengan fallback autentikasi Firestore/lokal (`finpay/lib/data/services/auth_service.dart`).
  - **Midtrans Sandbox API**: Pembuatan Snap Token (`POST /snap/v1/transactions`), cek status (`GET /v2/{orderId}/status`), serta sinkronisasi `midtrans_orders` menggunakan `package:http/http.dart` lintas platform dengan fallback simulator lokal (`finpay/lib/data/services/midtrans_service.dart`).
  - **Standar EMVCo QRIS Engine**: Parser & encoder payload TLV (*Tag-Length-Value*) beserta kalkulasi checksum `CRC16/CCITT-FALSE` mandiri (`finpay/lib/data/models/qris_model.dart`).
  - **Pure Dart PDF 1.4 Engine**: Pembuat dokumen e-Statement `.pdf` murni beserta pengunduh lintas platform (`finpay/lib/core/utils/pdf_statement_generator.dart`, `pdf_downloader_web.dart`, `pdf_downloader_io.dart`, `pdf_downloader_stub.dart`).

---

## 2. Arsitektur & Struktur Direktori Nyata

Workspace memiliki folder paket Flutter utama di `finpay/`. Di dalam `finpay/lib/`, proyek menggunakan pendekatan **Feature-First dikombinasikan dengan Layer-Based (`core`, `data`, `shared`)**:

```text
finpay/
├── pubspec.yaml               # Konfigurasi paket & dependencies Flutter
├── analysis_options.yaml      # Konfigurasi linter flutter_lints
├── lib/
│   ├── main.dart              # Entry point, FinPayApp, _AuthGate, & routing ('/', '/login', '/admin')
│   ├── core/                  # Layer fundamental & utilitas global
│   │   ├── theme/             # Design tokens (app_colors.dart, app_dimens.dart, app_text_styles.dart, app_theme.dart)
│   │   └── utils/             # Helper format Rupiah & generator file .pdf (currency_formatter.dart, pdf_statement_generator.dart, pdf_downloader_*.dart)
│   ├── data/                  # Layer data, domain model, state in-memory, & service backend
│   │   ├── dummy/             # In-memory store (dummy_data.dart)
│   │   ├── models/            # 9 file model (wallet_model.dart, transaction_model.dart, qris_model.dart, qris_merchant.dart, user_profile_model.dart, linked_account_model.dart, wealth_models.dart, support_chat_model.dart, menu_item_data.dart)
│   │   └── services/          # 8 singleton services:
│   │                          # - Bagian Ali: wallet_service.dart, transaction_service.dart, midtrans_service.dart, qris_service.dart, support_chat_service.dart
│   │                          # - Bagian Pidi: auth_service.dart, account_service.dart, wealth_service.dart
│   ├── features/              # Modul fitur mandiri berbasis halaman/tab
│   │   ├── auth/              # Halaman Login & Register Email/Password + Referral (login_page.dart)
│   │   ├── main/              # Shell navigasi utama IndexedStack + bottom nav (main_page.dart, widgets/finpay_bottom_nav_bar.dart)
│   │   ├── home/              # Tab Beranda & 10 widget spesifik beranda (home_page.dart, widgets/*)
│   │   ├── history/           # Tab Riwayat Transaksi, filter rentang waktu, detail, & unduh e-Statement .PDF (history_page.dart, e_statement_page.dart, transaction_detail_page.dart, widgets/*)
│   │   ├── pay/               # Tab Scan QRIS, QRIS Saya, & Tarik Tunai (pay_page.dart, widgets/*)
│   │   ├── finance/           # Tab Portofolio Keuangan, kesehatan finansial, & target menabung (finance_page.dart, widgets/*)
│   │   ├── account/           # Tab Akun, FinPoin & Referral, PIN, KYC, Limit, Rekening/Kartu, & 15 sub-halaman (account_page.dart, pages/*, widgets/*)
│   │   ├── services/          # Halaman penuh layanan finansial (top_up_page.dart, transfer_page.dart, savings_page.dart, loan_page.dart, cash_flow_page.dart, promos_page.dart, service_navigation_helper.dart)
│   │   └── admin/             # Portal Web Admin Dashboard '/admin' (admin_dashboard_page.dart)
│   └── shared/                # Komponen UI lintas fitur
│       ├── dialogs/           # Bottom sheet aksi finansial & dialog struk (financial_action_sheets.dart, sheets/*, widgets/finpay_receipt_dialog.dart)
│       └── widgets/           # 7 reusable widgets (app_card.dart, icon_box.dart, menu_grid.dart, pill_badge.dart, qris_code_card.dart, rounded_progress_bar.dart, section_header.dart)
└── test/                      # Unit & widget tests (wallet_service_test.dart, qris_model_test.dart, pidi_services_test.dart, widget_test.dart)
```

### Aturan Batasan Layer (Layer Boundaries)
1. **`core/theme/`** dan **`core/utils/currency_formatter.dart`** adalah modul murni yang tidak mengimpor dari `data/`, `features/`, atau `shared/`. *(Pengecualian faktual: `core/utils/pdf_statement_generator.dart` mengimpor model dari `data/models/` untuk merender data transaksi ke byte PDF).*
2. **`data/`** hanya mengimpor dari `core/` (contoh: `AppColors` di `finpay/lib/data/dummy/dummy_data.dart` dan `finpay/lib/data/models/wealth_models.dart`). `data/services/` tidak boleh memegang referensi `BuildContext`.
3. **`shared/`** berisi komponen UI generik atau dialog transaksi yang dipakai lintas fitur (`finpay/lib/shared/widgets/app_card.dart`, `finpay/lib/shared/dialogs/financial_action_sheets.dart`).
4. **`features/`** mengonsumsi `core/`, `data/`, dan `shared/`. Widget spesifik fitur ditempatkan di `features/<nama_fitur>/widgets/`.

---

## 3. Standar Penulisan Kode (Coding Conventions)

### A. Penamaan (Naming Conventions)
- **File & Folder**: `snake_case.dart` (bukti: `finpay/lib/data/services/wallet_service.dart`, `finpay/lib/features/pay/widgets/qris_confirm_sheet.dart`).
- **Kelas, Enum, & Typedef**: `PascalCase` dengan sufiks sesuai peran:
  - Model: `*Model` / `*Data` / `*Payload` / `*Result` (bukti: `TransactionModel`, `UserProfileModel`, `MenuItemData`, `QrisPayload`, `MidtransOrderResult`).
  - Service: `*Service` (bukti: `WalletService`, `AuthService`, `AccountService`, `WealthService`).
  - Halaman utama/sub-halaman: `*Page` (bukti: `LoginPage`, `HomePage`, `HistoryPage`, `EStatementPage`).
  - Bottom sheet: `*Sheet` (bukti: `TransferActionSheet`, `RedeemPoinSheet`, `QrisConfirmSheet`).
  - Helper navigasi: `*NavigationHelper` (bukti: `ServiceNavigationHelper`, `AccountNavigationHelper`).
- **Variabel, Fungsi, & Parameter**: `camelCase`. Anggota privat diawali underscore (`_selectedPeriod`, `_syncWalletToFirestore`).
- **Namespace Konstanta**: Gunakan `abstract final class` dengan properti `static const` (bukti: `AppColors`, `AppSpacing`, `AppRadius`, `AppSizes`, `CurrencyFormatter`).

### B. Gaya Bahasa & Kutipan
- **Single Quotes**: Wajib menggunakan kutipan tunggal (`'...'`) untuk semua string sesuai `finpay/analysis_options.yaml`.
- **Immutability & `const`**:
  - Field pada Model dan Widget menggunakan `final` (dengan metode `copyWith` untuk pembaruan state pada `WalletModel`, `UserProfileModel`, `LinkedAccountModel`, `SavingGoalModel`, `LoanModel`, `PromoModel`, `SupportMessageModel`, `MidtransOrderResult`).
  - Gunakan `const` pada konstruktor widget dan deklarasi elemen statis.
- **Bahasa Komentar & UI**:
  - Teks antarmuka pengguna (UI), pesan `Exception`, dan komentar dokumentasi (`///`) ditulis dalam **Bahasa Indonesia**.
  - Identifier kode ditulis dalam **Bahasa Inggris** (kecuali fungsi domain spesifik seperti `CurrencyFormatter.rupiah` atau handler lokal seperti `_setorTabungan` di `finpay/lib/features/services/savings_page.dart`).

### C. Struktur Fungsi & Pemisahan Widget
- **Signature Fungsi**: Gunakan *named parameters* (`{required this.a, this.b}`) untuk konstruktor widget, model, dan method service.
- **Multiple Return Values**: Gunakan **Dart 3 Named Records** (bukti: `Future<({TransactionModel transaction, int monthlyInstallment})> disburseLoan(...)` di `finpay/lib/data/services/wallet_service.dart` dan `Future<({TransactionModel transaction, int cashAdded})> redeemFinPoin(...)` di `finpay/lib/data/services/account_service.dart`).
- **Widget Decomposition**: Buat *private StatelessWidget* di bagian bawah file (bukti: `_FilterChip` di `finpay/lib/features/history/history_page.dart`, `_AuthTabButton` di `finpay/lib/features/auth/login_page.dart`).

---

## 4. Manajemen State & Alur Data

Proyek ini **tidak menggunakan package state management eksternal** (seperti Bloc, Provider, atau Riverpod), melainkan mengandalkan arsitektur reaktif bawaan Flutter:

1. **Singleton Service + `ValueNotifier`**:
   - Setiap service dideklarasikan sebagai singleton dengan konstruktor privat (`ServiceName._()` dan `static final ServiceName instance = ServiceName._()`).
   - State reaktif diekspos melalui `ValueNotifier<T>`:
     - `AuthService.instance.isLoggedInNotifier` & `currentUserNotifier` (`finpay/lib/data/services/auth_service.dart`)
     - `AccountService.instance.userNotifier` & `linkedAccountsNotifier` (`finpay/lib/data/services/account_service.dart`)
     - `WalletService.instance.walletNotifier` (`finpay/lib/data/services/wallet_service.dart`)
     - `TransactionService.instance.transactionsNotifier` (`finpay/lib/data/services/transaction_service.dart`)
     - `WealthService.instance.savingGoalsNotifier`, `activeLoansNotifier`, & `promosNotifier` (`finpay/lib/data/services/wealth_service.dart`)
     - `MidtransService.instance.ordersNotifier` (`finpay/lib/data/services/midtrans_service.dart`)
     - `SupportChatService.instance.messagesNotifier` (`finpay/lib/data/services/support_chat_service.dart`)
   - UI mendengarkan perubahan state menggunakan `ValueListenableBuilder<T>`.
2. **Isolasi Sesi Multi-User & Sinkronisasi Firestore**:
   - Pengguna baru yang mendaftar melalui `AuthService.instance.register(...)` wajib memulai dengan **Saldo Rp 0** (`initialCash: 0`, `savingBalance: 0`) dan daftar transaksi kosong (`finpay/lib/data/services/auth_service.dart`).
   - Saat pengguna lama login melalui `AuthService.instance.login(...)`, sistem mencari profil pengguna di koleksi `users` Firebase Firestore dan memulihkan saldo (`wallets/{uid}`), riwayat transaksi (`transactions`), rekening (`linked_accounts`), tabungan (`saving_goals`), serta pinjaman (`loans`) milik `userId` tersebut.
3. **Ephemeral UI State**:
   - State lokal halaman dikelola dengan `StatefulWidget` dan `setState()`.
   - Semua `TextEditingController` dan `AnimationController` wajib di-`dispose()` pada `dispose()`.

---

## 5. Penanganan Error & Keamanan UI

1. **Validasi Bisnis & Domain Exceptions**:
   - Gunakan `QrisFormatException` (`finpay/lib/data/models/qris_model.dart`) untuk error validasi QRIS EMVCo.
   - Gunakan `Exception('Pesan Bahasa Indonesia')` untuk validasi transaksi, autentikasi, PIN, limit, dan penukaran FinPoin di layer service.
2. **Graceful Degradation pada Jaringan (Offline-Safe)**:
   - Panggilan HTTP menggunakan `.timeout(const Duration(seconds: 6))` (atau `connectionTimeout`) di dalam blok `try / catch (_)`.
   - Kegagalan jaringan tidak boleh menghentikan aplikasi; state lokal tetap berjalan dan menyediakan fallback aman.
3. **Anti-Crash UI & Layout Safety**:
   - Selalu periksa `if (!mounted) return;` setelah setiap `await` sebelum memanggil `setState`, `Navigator`, atau `ScaffoldMessenger`.
   - Hindari pembagian dengan nol (`NaN`) dan `Expanded(flex: 0)` saat saldo atau arus kas pengguna baru bernilai `0` (bukti: penjagaan `if (filledFlex > 0)` di `finpay/lib/shared/widgets/rounded_progress_bar.dart` dan `totalFlow <= 0` di `finpay/lib/features/history/widgets/monthly_summary_card.dart`).

---

## 6. Standar Pengujian (Testing)

- File pengujian berada di `finpay/test/`:
  - `finpay/test/wallet_service_test.dart`
  - `finpay/test/qris_model_test.dart`
  - `finpay/test/support_and_midtrans_service_test.dart`
  - `finpay/test/pidi_services_test.dart`
  - `finpay/test/widget_test.dart`
- Saat menulis unit test untuk service yang terhubung ke Firestore, kosongkan `FirebaseFirestoreConfig.projectId = ''` pada `setUp()` dan kembalikan ke `'finpay-app-4026a'` pada `tearDown()`.

---

## 7. Catatan Keterbatasan Audit (Limitations Note)

Sebagai bentuk transparansi audit anti-halusinasi, berikut adalah folder dan area yang **tidak diperiksa secara mendalam per baris kode** atau memiliki keterbatasan arsitektural saat ini:
1. **Folder Platform Native & Build Artifacts**: Folder `finpay/android/`, `finpay/ios/`, `finpay/web/`, `finpay/build/`, dan `finpay/.dart_tool/` tidak diaudit isi file konfigurasi native-nya (seperti `build.gradle`, `AndroidManifest.xml`, `Info.plist`, atau `index.html`) karena dikecualikan pada `finpay/analysis_options.yaml` dan merupakan boilerplate standar Flutter.
2. **Sub-Halaman Statis Sekunder di `features/account/pages/`**: Beberapa halaman informasi statis seperti `about_app_page.dart`, `devices_page.dart`, `help_center_page.dart`, `language_settings_page.dart`, `legal_page.dart`, `legal_terms_page.dart`, `notifications_settings_page.dart`, `profile_detail_page.dart`, `security_settings_page.dart`, dan `theme_settings_page.dart` hanya dipindai keberadaannya dan tidak dimodifikasi pada siklus pengembangan layanan finansial utama.
3. **Arsitektur Serverless Client-to-Firestore**: Proyek ini adalah aplikasi Flutter *client-side* tanpa server backend terpisah (seperti Node.js/Go). Oleh karena itu, "layer backend" diwakili oleh kelas-kelas `*Service` di `finpay/lib/data/services/` yang berkomunikasi langsung ke REST API Firebase Firestore dan Midtrans Sandbox.
