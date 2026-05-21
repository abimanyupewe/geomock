# **Product Requirements Document (PRD)**

**Nama Produk:** GeoMock Pro  
**Fase:** MVP (Minimum Viable Product)  
**Tanggal Dokumen:** \[Isi Tanggal\]  
**Pemilik Produk (PM):** \[Nama Anda\]  
**Status:** \[Draft / Under Review / Approved\]

## **1\. Ringkasan Eksekutif (Executive Summary)**

**Tujuan Dokumen:**  
Mendefinisikan kebutuhan fungsional dan non-fungsional untuk pembuatan MVP GeoMock Pro, sebuah aplikasi *mock location* berbasis peta (OpenStreetMap) yang ditargetkan untuk *developer* dan QA.  
**Visi Produk:**  
Menyediakan alat simulasi lokasi yang paling stabil, sederhana, dan ringan tanpa elemen UI yang mengganggu, memungkinkan tim menguji aplikasi mereka dengan presisi tinggi.

## **2\. Latar Belakang & Masalah (Problem Statement)**

* **Masalah:** Developer/QA kesulitan menguji fitur *Location-Based Services* (LBS) tanpa berpindah fisik. Aplikasi *spoofer* yang ada sering tidak stabil (*rubberbanding*), penuh iklan, dan dirancang untuk peretas *game*, bukan untuk *workflow testing* profesional.  
* **Solusi:** GeoMock Pro menawarkan *mocking* lokasi dengan API bawaan Android (LocationManager) yang dibungkus dengan UI peta OpenStreetMap yang bersih dan dijaga oleh *Foreground Service* agar tidak *force close*.

## **3\. Target Pengguna (User Personas)**

* **Persona 1: Andi (Android Developer):** Butuh melakukan tes fitur absensi berbasis radius lokasi dengan cepat dari meja kerjanya.  
* **Persona 2: Budi (QA Engineer):** Butuh mensimulasikan lokasi di berbagai titik koordinat di luar kota untuk memastikan fitur perhitungan tarif logistik berjalan benar.

## **4\. Tujuan & Metrik Kesuksesan (Goals & Success Metrics)**

* **Tujuan Bisnis/Produk:** Validasi kelayakan aplikasi di lingkungan internal/klien B2B sebelum pengembangan lebih lanjut.  
* **Key Performance Indicators (KPIs):**  
  * *Crash-free rate* \> 99%.  
  * Waktu aktif sesi (*Session duration*) stabil di *background* lebih dari \[X\] jam tanpa *rubberbanding*.

## **5\. Ruang Lingkup (Scope)**

### **5.1. In-Scope (Masuk dalam MVP ini)**

* Tampilan peta interaktif menggunakan OpenStreetMap (OSM).  
* Fitur pencarian lokasi atau *drop-pin* koordinat manual.  
* Tombol *Start/Stop Mocking Location*.  
* *Foreground Service* dengan notifikasi persisten agar aplikasi tetap hidup di latar belakang.  
* Distribusi manual (Direct APK/GitHub), **tidak** melalui Play Store.

### **5.2. Out-of-Scope (Ditunda ke Fase Berikutnya)**

* **Integrasi VPN/Proxy** (Permintaan klien untuk manipulasi IP ditunda ke versi/iterasi selanjutnya).  
* Sistem *login/authentication* pengguna (tidak perlu untuk MVP).

## **6\. Kebutuhan Fungsional (Functional Requirements)**

*Fungsionalitas spesifik yang harus bisa dilakukan aplikasi.*

| ID Fitur | Nama Fitur | Deskripsi (User Story) | Prioritas |
| :---- | :---- | :---- | :---- |
| F-01 | **Izin Akses Lokasi** | *Sebagai pengguna, saya akan diminta mengaktifkan "Developer Options" dan memilih GeoMock Pro sebagai "Mock Location App".* | High (P0) |
| F-02 | **Peta OSM Interaktif** | *Sebagai pengguna, saya bisa melihat peta, zoom in/out, dan menggeser peta dengan lancar.* | High (P0) |
| F-03 | **Pin Point Location** | *Sebagai pengguna, saya bisa tap di peta untuk menjatuhkan pin, dan aplikasi akan mengambil data koordinat (Lat/Long) tersebut.* | High (P0) |
| F-04 | **Start/Stop Spoofer** | *Sebagai pengguna, saya bisa menekan tombol "Play" untuk memulai injeksi lokasi, dan "Stop" untuk menghentikannya.* | High (P0) |
| F-05 | **Background Notif** | *Saat injeksi berjalan, harus ada notifikasi di status bar agar saya tahu aplikasi sedang aktif dan tidak dimatikan oleh sistem Android.* | High (P0) |

## **7\. Kebutuhan Non-Fungsional (Non-Functional Requirements)**

* **Kinerja & Stabilitas:** Aplikasi harus sangat ringan (ukuran APK minimal) dan tidak boros baterai meskipun berjalan di *background*.  
* **Kompatibilitas:** Mendukung minimal Android versi \[Misal: Android 8.0 Oreo\] hingga versi Android terbaru.  
* **Keamanan:** Aplikasi murni berjalan di sisi klien (lokal), tidak ada pengumpulan data lokasi pengguna ke *server* luar.  
* **Maintainability (Perawatan):** Kode harus ditulis mengikuti standar kualitas tinggi dan *best practices* (lihat bagian 10\) agar siap diskalakan.

## **8\. Alur Pengguna (User Flow)**

1. Buka Aplikasi \-\> Muncul peringatan untuk set "Mock Location App" di *Developer Settings*.  
2. Pengguna kembali ke aplikasi \-\> Melihat antarmuka Peta (OSM).  
3. Pengguna menggeser peta dan *tap* pada lokasi target (misal: Monas, Jakarta).  
4. Tekan tombol "Mulai Mocking".  
5. Beralih ke aplikasi target yang akan diuji (misal: Aplikasi Absensi).  
6. Kembali ke GeoMock Pro \-\> Tekan tombol "Berhenti" jika sudah selesai.

## **9\. Asumsi dan Ketergantungan (Assumptions & Dependencies)**

* **Ketergantungan:** Mengandalkan *library* pihak ketiga untuk peta (*flutter\_map*) dan layanan latar belakang Android.  
* **Asumsi:** Pengguna (Developer/QA) sudah memiliki pemahaman dasar tentang cara mengaktifkan "Developer Options" di perangkat Android mereka.

## **10\. Arsitektur & Teknologi (Tech Stack)**

Aplikasi akan dikembangkan menggunakan kerangka kerja **Flutter** dengan pendekatan **Clean Architecture**. Pemisahan lapisan (*Data, Domain, Presentation*) digunakan untuk menjaga agar *business logic* independen dari UI.  
**Daftar Package Flutter Utama yang Digunakan:**

* **flutter\_bloc**: Digunakan untuk *State Management*. Sangat ideal disandingkan dengan Clean Architecture untuk memisahkan *logic* dari UI.  
* **get\_it & injectable**: Digunakan untuk *Dependency Injection* (DI) guna mempermudah pemanggilan kelas dari berbagai layer (*Repository, UseCase, Data Source*).  
* **fpdart (atau dartz)**: Digunakan untuk menangani *error handling* secara fungsional menggunakan konsep Either\<Failure, Success\>, menjaga konsistensi *return type* dari *Repository*.  
* **flutter\_map & latlong2**: *Library* utama untuk menampilkan dan mengelola *OpenStreetMap* secara *native* di Flutter tanpa perlu API Key khusus.  
* **flutter\_background\_service**: Untuk memastikan aplikasi tetap hidup di latar belakang (*Foreground Service*) dan menampilkan notifikasi persisten saat *mock location* berjalan.  
* **shared\_preferences**: Untuk menyimpan konfigurasi lokal ringan.  
* ***Platform Channels (MethodChannel)***: **(Sangat Penting)** Flutter tidak memiliki package murni untuk mengeksekusi LocationManager.addTestProvider. Lapisan *Data* di Flutter akan menggunakan MethodChannel untuk berkomunikasi langsung dengan kode *Native Android (Kotlin)*.

### **Standar Pengembangan (*Best Practices*):**

Untuk memastikan kualitas aplikasi jangka panjang, tim developer diwajibkan menerapkan standar berikut:

* **Linter & Code Analysis:** Menggunakan aturan linter yang ketat (seperti very\_good\_analysis atau flutter\_lints bawaan dengan aturan tambahan) untuk memastikan kode Dart konsisten dan minim *code smell*.  
* **Unit Testing:** Logika bisnis di dalam lapisan *Domain (UseCases)* dan *State Management (Bloc/Cubit)* harus memiliki cakupan pengujian (*unit tests*) menggunakan mocktail atau mockito.  
* **Git Workflow & Conventional Commits:** Menggunakan sistem percabangan yang rapi (misal: *Git Flow*) dan standar *Conventional Commits* (seperti feat:, fix:, refactor:) agar riwayat perubahan mudah dilacak.  
* **Error Handling Global:** Menghindari aplikasi *crash* dengan membungkus blok kode krusial menggunakan try-catch yang diarahkan ke mekanisme *logging* sistem operasi.

## **11\. Rencana Rilis (Release Plan)**

* **Milestone 1:** Setup Clean Architecture, Linter, *Method Channel* Android, & Base UI (Minggu 1).  
* **Milestone 2:** Integrasi flutter\_map & Logic Mock Location (Minggu 2-3).  
* **Milestone 3:** Pengujian *Foreground Service* & Stabilitas *Background* (Minggu 4).  
* **Milestone 4:** Distribusi APK ke Klien (Akhir Minggu 4).