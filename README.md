# 📱 KeuanganKu - Aplikasi Manajemen Keuangan Personal

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</div>

<p align="center">
  <strong>Aplikasi manajemen keuangan pribadi yang powerful dengan fitur NFC Scanner, OCR Receipt, dan Analytics Dashboard</strong>
</p>

---

## ✨ Fitur Utama

### 🏠 Dashboard Interaktif
- **Real-time Balance Tracking** - Monitor saldo, pemasukan, dan pengeluaran secara real-time
- **Animated UI** - Pengalaman visual yang smooth dengan animasi elastis
- **Transaction History** - Riwayat transaksi lengkap dengan kategori

### 💳 NFC Flazz Scanner
- **Tap & Scan** - Scan kartu Flazz BCA langsung dari HP
- **Auto Detection** - Deteksi saldo otomatis menggunakan NFC
- **Secure Transaction** - Penyimpanan transaksi yang aman

### 📸 Smart Receipt Scanner (OCR)
- **AI-Powered OCR** - Ekstrak informasi dari foto struk belanja
- **Auto Parsing** - Deteksi otomatis merchant, tanggal, dan total
- **Receipt Preview** - Tampilan struk seperti nota asli

### 📊 Advanced Statistics
- **Interactive Charts** - Visualisasi data dengan Pie Chart & Bar Chart
- **Monthly Reports** - Laporan bulanan pemasukan dan pengeluaran
- **Trend Analysis** - Analisis tren keuangan Anda

### 🏷️ Smart Categories
- **Auto Categorization** - Kategorisasi transaksi otomatis
- **Custom Categories** - 13+ kategori siap pakai
- **Category Insights** - Detail pengeluaran per kategori

### 💾 Data Persistence
- **Local Storage** - Data tersimpan aman di perangkat
- **Auto Backup** - Penyimpanan otomatis setiap transaksi
- **Fast Performance** - Akses data yang cepat dan responsif

---

## 📸 Screenshots

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/Rafliarjunapratama/aplikasikeuangan/blob/main/gambargithub/Screenshot%202025-11-03%20211743.png" width="200" alt="Onboarding"></td>
      <td><img src="https://github.com/Rafliarjunapratama/aplikasikeuangan/blob/main/gambargithub/Screenshot%202025-11-03%20211832.png" width="200" alt="Dashboard"></td>
      <td><img src="https://github.com/Rafliarjunapratama/aplikasikeuangan/blob/main/gambargithub/Screenshot%202025-11-03%20211839.png" width="200" alt="Statistics"></td>
    </tr>
    <tr>
      <td align="center"><b>Onboarding</b></td>
      <td align="center"><b>Dashboard</b></td>
      <td align="center"><b>Statistics</b></td>
    </tr>
    <tr>
      <td><img src="https://github.com/Rafliarjunapratama/aplikasikeuangan/blob/main/gambargithub/Screenshot%202025-11-03%20211847.png" width="200" alt="Categories"></td>
      <td><img src="https://github.com/Rafliarjunapratama/aplikasikeuangan/blob/main/gambargithub/Screenshot%202025-11-03%20211856.png" width="200" alt="OCR Scanner"></td>
      <td><img src="https://github.com/Rafliarjunapratama/aplikasikeuangan/blob/main/gambargithub/Screenshot%202025-11-03%20211922.png" width="200" alt="Add Transaction"></td>
    </tr>
    <tr>
      <td align="center"><b>Categories</b></td>
      <td align="center"><b>OCR Scanner</b></td>
      <td align="center"><b>Add Transaction</b></td>
    </tr>
  </table>
</div>

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **SharedPreferences** | Local data persistence |
| **fl_chart** | Data visualization & charts |
| **flutter_nfc_kit** | NFC card reading |
| **google_mlkit_text_recognition** | OCR text extraction |
| **image_picker** | Camera & gallery access |
| **intl** | Date formatting & localization |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI & Animations
  font_awesome_flutter: ^10.0.0
  
  # Data Management
  shared_preferences: ^2.2.0
  intl: ^0.18.0
  
  # Charts & Visualization
  fl_chart: ^0.65.0
  
  # NFC & Hardware
  flutter_nfc_kit: ^3.3.1
  
  # Image & OCR
  image_picker: ^1.0.4
  google_mlkit_text_recognition: ^0.11.0
  path_provider: ^2.1.1
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 atau lebih tinggi
- Dart SDK 3.0 atau lebih tinggi
- Android Studio / VS Code
- Perangkat Android dengan NFC (untuk fitur Flazz Scanner)

### Installation

1. **Clone repository**
```bash
git clone https://github.com/Rafliarjunapratama/keuanganku.git
cd keuanganku
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 📱 Platform Support

| Platform | Support |
|----------|---------|
| Android | ✅ Full Support |
| iOS | ⚠️ Limited (NFC hanya iPhone 7+) |
| Web | ❌ Tidak tersedia |
| Desktop | ❌ Tidak tersedia |

---

## 🎨 Design Principles

### Color Palette
- **Primary**: Teal (`#009688`)
- **Background**: Dark Gradient (`#101413` → `#1a1f1d`)
- **Accent**: Teal Accent (`#64FFDA`)
- **Success**: Green (`#4CAF50`)
- **Error**: Red (`#F44336`)

### UI/UX Features
- **Dark Mode**: Modern dark theme untuk kenyamanan mata
- **Smooth Animations**: Transisi halus dengan `AnimationController`
- **Responsive Layout**: Adaptif untuk berbagai ukuran layar
- **Glassmorphism**: Efek transparan modern
- **Haptic Feedback**: Getaran saat interaksi penting

---

## 📂 Project Structure

```
lib/
├── dashboard/
│   ├── dashboard.dart          # Main dashboard screen
│   ├── add.dart                # Add transaction screen
│   ├── stats.dart              # Statistics & charts
│   ├── kategori.dart           # Categories management
│   ├── scan_struk.dart         # OCR receipt scanner
│   ├── info.dart               # App info & about
│   └── button.dart             # Bottom navigation
├── halamanpertama.dart         # Onboarding screens
└── main.dart                   # App entry point
```

---

## 🔐 Permissions Required

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

## 🎯 Roadmap

- [x] Dashboard dengan balance tracking
- [x] NFC Flazz BCA scanner
- [x] OCR receipt scanning
- [x] Statistics & analytics
- [x] Category management
- [ ] Cloud backup (Firebase)
- [ ] Multi-currency support
- [ ] Budget planning
- [ ] Export to PDF/Excel
- [ ] Biometric authentication

---

## 🐛 Known Issues

1. **NFC Scanner**: Hanya berfungsi pada perangkat yang mendukung NFC
2. **OCR Accuracy**: Tergantung kualitas foto struk
3. **iOS NFC**: Memerlukan iPhone 7 atau lebih baru

---

## 🤝 Contributing

Kontribusi sangat diterima! Silakan ikuti langkah berikut:

1. Fork repository ini
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👨‍💻 Developer

<div align="center">
  <img src="https://avatars.githubusercontent.com/u/130772818" width="100" style="border-radius: 50%">
  <h3>Muhamad Rafli Arjuna Pratama</h3>
  <p>Flutter Developer</p>
  
  [![GitHub](https://img.shields.io/badge/GitHub-Rafliarjunapratama-black?style=flat-square&logo=github)](https://github.com/Rafliarjunapratama)
  [![Email](https://img.shields.io/badge/Email-dev@keuanganku.com-red?style=flat-square&logo=gmail)](mailto:dev@keuanganku.com)
</div>

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Rafliarjunapratama/keuanganku&type=Date)](https://star-history.com/#Rafliarjunapratama/keuanganku&Date)

---

## 💬 Support

Jika Anda menemukan bug atau memiliki saran, silakan buat [issue](https://github.com/Rafliarjunapratama/aplikasikeuangan/issues) di repository ini.

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/Rafliarjunapratama">Muhamad Rafli Arjuna Pratama</a></p>
  <p>© 2025 KeuanganKu - All Rights Reserved</p>
</div>
