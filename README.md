# Yuang

Aplikasi tracking keuangan pribadi berbasis Flutter dengan desain mobile banking modern. Yuang membantu pengguna memantau pemasukan dan pengeluaran harian secara sederhana menggunakan penyimpanan lokal.

## Deskripsi

Yuang adalah aplikasi manajemen keuangan pribadi yang dirancang untuk memudahkan pencatatan transaksi sehari-hari. Tanpa perlu akun atau koneksi internet, semua data tersimpan langsung di perangkat menggunakan SharedPreferences. Dengan tampilan yang terinspirasi dari aplikasi mobile banking, Yuang menghadirkan pengalaman pengelolaan keuangan yang intuitif dan ringan.

Aplikasi ini dikembangkan sebagai tugas Flutter dari Motion Lab.

## Fitur Utama

### 1. Dashboard Beranda
- Kartu saldo utama dengan tampilan total saldo terkini
- Toggle sembunyikan/tampilkan saldo
- Top up saldo manual langsung dari kartu
- Ringkasan pemasukan dan pengeluaran bulan berjalan
- Daftar 5 transaksi terbaru

### 2. Manajemen Transaksi
- Tambah pemasukan dan pengeluaran melalui tombol di bottom navigation
- Input nominal otomatis terformat sebagai Rupiah (contoh: 12.000, 1.500.000)
- Pilihan kategori dengan ikon untuk setiap jenis transaksi
- Kolom catatan opsional untuk keterangan tambahan
- Saldo otomatis terupdate setiap ada transaksi baru

### 3. Riwayat Transaksi
- Semua transaksi dikelompokkan berdasarkan tanggal
- Filter berdasarkan jenis: Semua, Pemasukan, Pengeluaran
- Hapus transaksi dengan konfirmasi dialog
- Saldo otomatis disesuaikan saat transaksi dihapus

### 4. Statistik
- Ringkasan pemasukan dan pengeluaran bulan berjalan
- Pie chart perbandingan pemasukan vs pengeluaran
- Breakdown pengeluaran per kategori dengan progress bar dan persentase

### 5. Profil
- Informasi pengguna: nama, email, nomor telepon
- Edit profil langsung dari halaman yang sama
- Statistik total transaksi, total pemasukan, dan total pengeluaran
- Tanggal bergabung sebagai member
- Opsi reset semua data aplikasi

## Screenshot Aplikasi
Halaman Awal
<img width="828" height="1792" alt="localhost_9280_(iPhone XR)" src="https://github.com/user-attachments/assets/aa50e1e0-659a-4ad3-beda-cf816d0ef514" />
Halaman Beranda
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (1)" src="https://github.com/user-attachments/assets/134371eb-c368-4f6d-8fba-ce75959349ae" />
Popup unutk topup
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (2)" src="https://github.com/user-attachments/assets/6933af72-b7bc-4be6-8599-11a044986bd4" />
Halaman Input Pengeluaran 
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (3)" src="https://github.com/user-attachments/assets/99cc75c7-a6af-4f7a-b08c-2b155c88d581" />
Halaman Input Pemasukkan 
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (4)" src="https://github.com/user-attachments/assets/3001cc7d-e246-4c54-be3f-01cb894d260d" />
Halaman Riwayat
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (5)" src="https://github.com/user-attachments/assets/e4430d7e-2882-488c-a735-07b9ed2c9c26" />
Halaman Statistik
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (6)" src="https://github.com/user-attachments/assets/83a70829-98f3-46c4-95c2-6bdaf95cce43" />
Halaman Profil
<img width="828" height="1792" alt="localhost_9280_(iPhone XR) (7)" src="https://github.com/user-attachments/assets/7659bd46-b997-4aa2-b634-b4b718216195" />



## Cara Menjalankan Aplikasi

### Prerequisites
- Flutter SDK versi 3.0.0 atau lebih baru
- Dart SDK
- Android Studio atau VS Code dengan Flutter extension
- Emulator Android/iOS atau perangkat fisik, atau Google Chrome untuk web

### Instalasi

1. Clone atau download repository ini
```bash
git clone <repository-url>
cd yuang
```

2. Install dependencies
```bash
flutter pub get
```

3. Jalankan aplikasi
```bash
# Mobile
flutter run

# Chrome / Web
flutter run -d chrome
```

### Build APK

```bash
flutter build apk
```

File APK tersimpan di: `build/app/outputs/flutter-apk/`

## Cara Menggunakan

### Pertama Kali Buka Aplikasi
- Isi nama, email (opsional), dan saldo awal
- Data tersimpan lokal dan langsung bisa digunakan

### Mencatat Transaksi
- Tap tombol `+` di tengah bottom navigation
- Pilih **Pemasukan** atau **Pengeluaran**
- Isi nominal, nama transaksi, kategori, dan catatan (opsional)
- Tap **Simpan** — saldo otomatis terupdate

### Top Up Saldo
- Di halaman Beranda, tap tombol **Top Up** pada kartu saldo
- Masukkan nominal yang ingin ditambahkan

### Melihat Riwayat
- Tap tab **Riwayat** di bottom navigation
- Gunakan filter chip untuk menyaring jenis transaksi
- Tap ikon `×` pada transaksi untuk menghapus

### Melihat Statistik
- Tap tab **Statistik** untuk melihat grafik dan breakdown kategori
- Data yang ditampilkan adalah transaksi bulan berjalan

### Mengedit Profil
- Tap tab **Profil**
- Tap **Edit Profil** dan ubah data yang diinginkan
- Tap **Simpan**

## Struktur Folder

```
lib/
├── main.dart
├── app/
│   ├── bindings/
│   ├── data/
│   │   ├── models/
│   │   └── services/
│   ├── modules/
│   │   ├── home/
│   │   ├── transaction/
│   │   ├── history/
│   │   ├── profile/
│   │   └── splash/
│   ├── routes/
│   ├── themes/
│   └── widgets/
└── utils/
```

## Teknologi yang Digunakan

| Komponen | Teknologi |
|---|---|
| Framework | Flutter |
| State Management | GetX |
| Penyimpanan Lokal | SharedPreferences |
| Format Mata Uang | intl (id_ID) |
| Grafik | fl_chart |
| Arsitektur | MVC dengan GetX |

## Catatan Pengembangan

- Semua data tersimpan lokal, tidak memerlukan koneksi internet
- Format mata uang menggunakan Rupiah (Rp) dengan pemisah titik ribuan
- Aplikasi dapat dijalankan di Android, iOS, maupun Chrome
- Saldo menyesuaikan otomatis saat transaksi ditambah atau dihapus


## Vide Penjelasan Aplikasi
https://drive.google.com/drive/folders/1a4hu2OPJd49s5tmAxcJB0Mk7k8zS6som?usp=sharing

## Pembuat

AHMAD RAFIANSYAH 
NIM: 103012400153

Tugas Flutter - Motion Lab
