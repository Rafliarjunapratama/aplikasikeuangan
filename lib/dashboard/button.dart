  import 'package:flutter/material.dart';
  import 'package:keuanganku/dashboard/dashboard.dart';
  import 'package:keuanganku/dashboard/info.dart';
  import 'package:keuanganku/dashboard/kategori.dart';
  import 'package:keuanganku/dashboard/scan_struk.dart';
  import 'package:keuanganku/dashboard/stats.dart'; // nanti bisa ganti ke file lain misalnya Statistik
  // import halaman lain sesuai kebutuhanmu

  class BottomMenu extends StatefulWidget {
    const BottomMenu({super.key});

    @override
    State<BottomMenu> createState() => _BottomMenuState();
  }

  class _BottomMenuState extends State<BottomMenu> {
    int _selectedIndex = 0;

    // daftar halaman yang ingin ditampilkan
    final List<Widget> _pages = [
      const Dashboardawal(),
      const CategoriesPage(), // ganti dengan StatistikScreen()
      const StatsPage(), // ganti dengan KategoriScreen()
      const ScanReceiptScreen(),
      const InfoPage(), // ganti dengan ScanScreen()
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xff101413),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xff1c2021),
          selectedItemColor: const Color(0xffbfc8c5),
          unselectedItemColor: const Color(0xff324b48),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromARGB(30, 255, 255, 255),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.home, color: Colors.white),
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              activeIcon: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromARGB(30, 255, 255, 255),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.bar_chart, color: Colors.white),
                ),
              ),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Kategori',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Scan Struk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: 'Info Aplikasi',
            ),
          ],
        ),
      );
    }
  }
