# **System & UI Design Document: GeoMock Pro (MVP)**

**Terkait dengan PRD:** GeoMock Pro MVP  
**Fokus Desain:** Antarmuka Pengguna (UI/UX) dan Arsitektur Sistem (Technical Design)

## **1\. Panduan UI/UX (User Interface & User Experience)**

Karena target penggunanya adalah *Developer* dan *QA Engineer*, desain harus mengutamakan **Fungsionalitas, Kecepatan, dan Kejelasan** di atas estetika yang berlebihan.

### **1.1. Tema Visual (Design System)**

* **Tema Warna:** Mengusung gaya **Clean UI** dengan latar belakang dominan **Putih (*Clean White*)** dan warna primer **Biru (*Tech Blue/Ocean Blue*)**. Kombinasi ini memberikan kesan profesional, modern, ringan, dan tingkat keterbacaan yang tinggi (*high contrast*). Warna merah (*Alert Red*) digunakan khusus untuk aksi destruktif atau menghentikan proses.  
* **Tipografi:** *Font sans-serif* yang bersih (seperti Roboto, Inter, atau SF Pro). Angka koordinat harus menggunakan *monospace font* (seperti Fira Code atau Roboto Mono) agar presisi desimal mudah dibaca dan selaras.  
* **Elevasi & Bayangan:** Menggunakan *drop shadow* yang sangat lembut (soft shadow) pada elemen melayang (kartu koordinat, tombol) agar terlihat menonjol dari latar belakang peta yang terang.

### **1.2. Daftar Layar (Screens)**

#### **A. Layar Izin & Persiapan (Setup Screen)**

* **Kondisi:** Muncul jika izin ACCESS\_FINE\_LOCATION belum diberikan, atau GeoMock Pro belum dipilih sebagai "Mock Location App" di opsi *Developer Settings* Android.  
* **Elemen UI:**  
  * Latar belakang: Putih bersih.  
  * Ilustrasi/Ikon Peringatan: Ikon roda gigi atau peta berwarna biru.  
  * Teks instruksi: Hitam keabuan (*Dark Grey*) agar nyaman dibaca: "Mohon pilih GeoMock Pro di pengaturan Mock Location."  
  * Tombol utama: Berbentuk *rounded rectangle* berwarna Biru penuh dengan teks putih ("Buka Pengaturan Developer"). Menekan tombol ini menggunakan *Intent* untuk langsung melempar user ke pengaturan Android.

#### **B. Layar Utama (Map Screen) \- Core UI**

* **Kondisi:** Muncul setelah semua perizinan selesai.  
* **Elemen UI:**  
  * **Full Screen Map:** Peta dari *OpenStreetMap* (flutter\_map) memenuhi layar (disarankan menggunakan *layer* peta bergaya terang/standar).  
  * **Search Bar (Floating, Top):** Kotak pencarian berwarna putih dengan bayangan lembut. Memiliki ikon kaca pembesar berwarna biru. (Opsional untuk MVP, atau cukup teks indikator koordinat saat ini).  
  * **Center Pin/Marker:** Ikon pin lokasi berwarna Biru khas yang kontras dengan warna peta.  
  * **Coordinate Card (Floating, Bottom):** Panel melayang di bagian bawah dengan *background* putih dan sudut membulat (*rounded corners*):  
    * Label Koordinat: Lat: \-6.2088, Lng: 106.8456 (teks *monospace* warna gelap).  
    * Status Text: "Menunggu" (warna abu-abu) / "Mocking Aktif" (warna biru tebal).  
  * **Primary Action Button (FAB):** Tombol bulat besar (seperti tombol *Play*).  
    * **State Siap:** Berwarna **Biru** dengan ikon *Play* (Mulai simulasi).  
    * **State Aktif:** Berubah menjadi **Merah** dengan ikon kotak *Stop* (Hentikan simulasi), disertai animasi *ripple* (riak air) lembut di sekeliling tombol untuk menandakan proses latar belakang sedang berjalan.

## **2\. Arsitektur Sistem (Technical Design)**

Sesuai PRD, proyek menggunakan **Flutter** dengan **Clean Architecture**. Berikut adalah rancangan struktur direktori dan tanggung jawab tiap komponen.

### **2.1. Struktur Folder (Clean Architecture)**

lib/  
├── core/                   \# Utilitas global, error handling, DI, tema  
│   ├── errors/             \# Kelas Failure (fpdart)  
│   ├── di/                 \# Setup injectable & get\_it  
│   ├── theme/              \# Definisi warna Putih & Biru, tipografi (Inter/Roboto)  
│   └── platform/           \# MethodChannel wrapper  
├── features/  
│   └── mock\_location/  
│       ├── data/           \# Layer Data  
│       │   ├── datasources/ \# Pemanggilan Native (MethodChannel)  
│       │   ├── models/     \# Model data  
│       │   └── repositories/\# Implementasi dari Domain Repository  
│       ├── domain/         \# Layer Domain (Business Logic murni)  
│       │   ├── entities/   \# Objek bisnis (misal: LocationCoordinates)  
│       │   ├── repositories/\# Kontrak antarmuka (Abstract class)  
│       │   └── usecases/   \# StartMockingUseCase, StopMockingUseCase  
│       └── presentation/   \# Layer UI & State Management  
│           ├── bloc/       \# MockLocationBloc (State Management)  
│           ├── pages/      \# MapPage, SetupPage  
│           └── widgets/    \# FloatingActionButton, CoordinateCard  
└── main.dart               \# Entry point

### **2.2. Desain Komunikasi (Data Flow)**

1. **User Interaksi:** User menekan tombol "Play" (Biru) di MapPage.  
2. **Presentation (BLoC):** MockLocationBloc menerima *event* StartMockingEvent(lat, lng) dan mengubah status menjadi loading.  
3. **Domain (UseCase):** BLoC memanggil StartMockingUseCase.execute(lat, lng).  
4. **Data (Repository):** UseCase memanggil MockLocationRepositoryImpl.startMocking().  
5. **Data (DataSource/Native):** Repository memanggil fungsi di *MethodChannel* MethodChannel('geomock/location').  
6. **Native (Android/Kotlin):**  
   * Kode Kotlin menerima koordinat.  
   * Memulai Foreground Service (memunculkan notifikasi persisten).  
   * Mengeksekusi LocationManager.addTestProvider dan menyuntikkan (inject) koordinat ke OS.  
7. **Return:** Mengembalikan status Success (atau Failure) kembali ke lapisan Presentation (BLoC) menggunakan Either dari fpdart, yang lalu mengubah UI tombol menjadi "Stop" (Merah).

## **3\. Spesifikasi Native Bridge (Method Channel Contract)**

Karena ini fitur sistem (*spoofer*), aplikasi Flutter butuh "jembatan" ke kode Native Android.

* **Channel Name:** com.yourdomain.geomock/location  
* **Methods yang harus diimplementasikan di sisi Kotlin (MainActivity.kt atau *Service*):**

| Method Name | Parameter (Arguments) | Deskripsi (Tugas di Kotlin) | Return (Ke Flutter) |
| :---- | :---- | :---- | :---- |
| checkMockPermission | \- | Cek apakah app ini sudah diset sebagai Mock App di pengaturan. | Boolean (true/false) |
| startMocking | Map{"lat": Double, "lng": Double} | Menghidupkan *Foreground Service*, mulai injeksi GPS ke LocationManager. | Boolean (Success state) |
| stopMocking | \- | Menghentikan injeksi lokasi, mematikan *Foreground Service*. | Boolean |

## **4\. Keamanan & Stabilitas Baterai (Background Service)**

* **Wakeloak & Foreground Service:** Saat tombol *Play* ditekan, aplikasi akan memanggil flutter\_background\_service. Layanan ini akan berjalan dengan notifikasi persisten agar OS tidak "membunuh" proses tersebut.  
* **Interval Injeksi:** Untuk menghindari *rubberbanding* (kembali ke lokasi asli sesaat), *looping* injeksi di *native layer* harus disetel sekitar 500ms hingga 1000ms per injeksi. Rentang waktu ini menjaga keseimbangan antara stabilitas koordinat dan efisiensi konsumsi baterai perangkat.