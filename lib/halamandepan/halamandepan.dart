import 'package:flutter/material.dart';
import 'package:keuanganku/dashboard/button.dart';
import 'package:keuanganku/dashboard/dashboard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Halamanpertama extends StatefulWidget {
  @override
  _HalamanpertamaState createState() => _HalamanpertamaState();
}

class _HalamanpertamaState extends State<Halamanpertama> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // 🎨 Warna utama per halaman
  final List<Color> _pageColors = [
    Colors.teal,
    Colors.blue,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff101413),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Kelola Keuangan',
                    colorbackground: Colors.teal.withOpacity(0.2),
                    coloricondannamajudul: Colors.teal,
                    description:
                        'Catat semua pemasukkan dan pengeluaran Anda dengan mudah dan praktis',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  _buildSlide(
                    icon: Icons.camera_alt_outlined,
                    title: 'Scan Flazz',
                    colorbackground: Colors.blue.withOpacity(0.2),
                    coloricondannamajudul: Colors.blue,
                    description: 'Gunakan kamera untuk scan kartu Flazz Anda',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  _buildSlide(
                    icon: Icons.bar_chart,
                    title: 'Statistik Laporan',
                    colorbackground: Colors.purple.withOpacity(0.2),
                    coloricondannamajudul: Colors.purple,
                    description:
                        'Pantau data keuangan Anda dalam bentuk grafik balok',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  _buildSlide(
                    icon: FontAwesomeIcons.piggyBank,
                    title: 'Mulai Sekarang',
                    colorbackground: Colors.orange.withOpacity(0.2),
                    coloricondannamajudul: Colors.orange,
                    description:
                        'Daftar gratis dan mulai kelola keuangan Anda hari ini juga!',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildDotsIndicator(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.08,
                0,
                screenWidth * 0.08,
                16,
              ),
              child: _buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String description,
    required Color colorbackground,
    required Color coloricondannamajudul,
    required double screenHeight,
    required double screenWidth,
  }) {
    // Ukuran responsif yang lebih kecil untuk layar kecil
    final iconContainerSize = (screenWidth * 0.3).clamp(100.0, 140.0);
    final iconSize = iconContainerSize * 0.5;
    final titleSize = (screenWidth * 0.06).clamp(20.0, 26.0);
    final descriptionSize = (screenWidth * 0.038).clamp(14.0, 16.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Center(
                        child: Container(
                          width: iconContainerSize,
                          height: iconContainerSize,
                          decoration: BoxDecoration(
                            color: colorbackground,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: iconSize,
                              color: coloricondannamajudul,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: coloricondannamajudul,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Flexible(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: descriptionSize,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pageColors.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? _pageColors[index]
                : Colors.grey.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton() {
    String _textbuttonan = "Selanjutnya";

    if (_currentPage == _pageColors.length - 1) {
      _textbuttonan = "Mulai Sekarang";
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_currentPage == _pageColors.length - 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomMenu()),
            );
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _pageColors[_currentPage],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _textbuttonan,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
