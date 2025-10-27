import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child:Text('Disalin: $text', overflow: TextOverflow.ellipsis,
            ),)
          ],
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff101413),
            Color(0xff1a1f1d),
            Color(0xff0f1412),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.tealAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const     Expanded(
                          child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                          'Tentang Aplikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ), overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Informasi & Bantuan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),)
                  ],
                ),
                const SizedBox(height: 32),

                // App Info Card
                _buildInfoCard(
                  icon: Icons.account_balance_wallet,
                  title: 'KeuanganKu',
                  subtitle: 'Versi 1.0.0',
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.tealAccent],
                  ),
                ),
                const SizedBox(height: 16),

                // Features Section
                _buildSectionTitle('Fitur Utama'),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.nfc,
                  title: 'NFC Flazz Scanner',
                  description: 'Scan kartu Flazz BCA untuk cek saldo otomatis',
                  color: Colors.cyan,
                ),
                _buildFeatureItem(
                  icon: Icons.add_circle_outline,
                  title: 'Pencatatan Transaksi',
                  description: 'Catat pemasukan dan pengeluaran dengan mudah',
                  color: Colors.blue,
                ),
                _buildFeatureItem(
                  icon: Icons.category,
                  title: 'Kategori Otomatis',
                  description: 'Kelola transaksi berdasarkan kategori',
                  color: Colors.purple,
                ),
                _buildFeatureItem(
                  icon: Icons.bar_chart,
                  title: 'Statistik & Grafik',
                  description: 'Visualisasi keuangan dalam bentuk grafik',
                  color: Colors.orange,
                ),
                _buildFeatureItem(
                  icon: Icons.camera_alt,
                  title: 'Scan Struk',
                  description: 'Input transaksi dari foto struk belanja',
                  color: Colors.pink,
                ),
                const SizedBox(height: 24),

                // Tips Section
                _buildSectionTitle('Tips Penggunaan'),
                const SizedBox(height: 12),
                _buildTipCard(
                  '💡',
                  'Scan NFC',
                  'Letakkan kartu Flazz di bagian belakang HP saat scanning',
                ),
                _buildTipCard(
                  '📊',
                  'Pantau Statistik',
                  'Cek grafik pengeluaran untuk kontrol keuangan lebih baik',
                ),
                _buildTipCard(
                  '🏷️',
                  'Gunakan Kategori',
                  'Pilih kategori yang tepat agar laporan lebih akurat',
                ),
                _buildTipCard(
                  '💾',
                  'Backup Rutin',
                  'Data tersimpan lokal, pastikan HP dalam kondisi baik',
                ),
                const SizedBox(height: 24),

                // Developer Info
                _buildSectionTitle('Developer'),
                const SizedBox(height: 12),
                _buildDeveloperCard(context),
                const SizedBox(height: 24),

                // Tech Stack
                _buildSectionTitle('Teknologi'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTechChip('Flutter', Icons.flutter_dash),
                    _buildTechChip('Dart', Icons.code),
                    _buildTechChip('NFC', Icons.nfc),
                    _buildTechChip('SharedPreferences', Icons.storage),
                    _buildTechChip('Material Design', Icons.design_services),
                  ],
                ),
                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Made with ❤️ Muhamad Rafli \n Arjuna Pratama',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2025 KeuanganKu',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
              Expanded(
                          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),overflow: TextOverflow.ellipsis,
              ),
            ],
          ),)
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String emoji, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildDeveloperCard(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.teal.withOpacity(0.1), Colors.transparent],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.teal.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Muhamad Rafli Arjuna Pratama',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Flutter Developer',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Menggunakan LayoutBuilder untuk deteksi ukuran
        LayoutBuilder(
          builder: (context, constraints) {
            // Jika lebar kurang dari 180, gunakan Column
            if (constraints.maxWidth < 180) {
              return Column(
                children: [
                  _buildContactButton(
                    context,
                    icon: Icons.email,
                    label: 'Email',
                    value: 'dev@keuanganku.com',
                  ),
                  const SizedBox(height: 12),
                  _buildContactButton(
                    context,
                    icon: Icons.code,
                    label: 'GitHub',
                    value: 'https://github.com/Rafliarjunapratama',
                  ),
                ],
              );
            }
            // Jika lebar cukup, gunakan Row
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactButton(
                  context,
                  icon: Icons.email,
                  label: 'Email',
                  value: 'dev@keuanganku.com',
                ),
                const SizedBox(width: 12),
                _buildContactButton(
                  context,
                  icon: Icons.code,
                  label: 'GitHub',
                  value: 'https://github.com/Rafliarjunapratama',
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.teal, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.tealAccent, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
