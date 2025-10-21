import 'package:flutter/material.dart';

void main() {
  runApp(const GojekApp());
}

class GojekApp extends StatelessWidget {
  const GojekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gojeks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xff00AA13),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const GojekHomePage(),
    );
  }
}

class GojekHomePage extends StatefulWidget {
  const GojekHomePage({super.key});

  @override
  State<GojekHomePage> createState() => _GojekHomePageState();
}

class _GojekHomePageState extends State<GojekHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PromosPage(),
    const OrdersPage(),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff00AA13),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promos'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(screenWidth),
              const SizedBox(height: 16),
              _buildSearchBar(screenWidth),
              const SizedBox(height: 20),
              _buildGopayCard(screenWidth),
              const SizedBox(height: 24),
              _buildMainServices(screenWidth),
              const SizedBox(height: 24),
              _buildXPCard(screenWidth),
              const SizedBox(height: 24),
              _buildQuickAccess(screenWidth),
              const SizedBox(height: 24),
              _buildPromoSection(screenWidth),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff00AA13), Color(0xff00D41D)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budi Santoso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.045).clamp(16.0, 18.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: const Color(0xff00AA13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              'Cari layanan, makanan, & tujuan',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: (screenWidth * 0.037).clamp(13.0, 15.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGopayCard(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff00AED6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'gopay',
                    style: TextStyle(
                      color: Color(0xff00AED6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rp 127.500',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Tap untuk riwayat',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _gopayAction(Icons.add, 'Top Up'),
                _gopayAction(Icons.payments, 'Pay'),
                _gopayAction(Icons.explore, 'Explore'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gopayAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xff00AED6)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildMainServices(double screenWidth) {
    final services = [
      {'icon': Icons.motorcycle, 'label': 'GoRide', 'color': Color(0xff00AA13)},
      {'icon': Icons.directions_car, 'label': 'GoCar', 'color': Color(0xff00AA13)},
      {'icon': Icons.restaurant, 'label': 'GoFood', 'color': Color(0xffEE2737)},
      {'icon': Icons.shopping_bag, 'label': 'GoSend', 'color': Color(0xff00AA13)},
      {'icon': Icons.shopping_cart, 'label': 'GoMart', 'color': Color(0xffEE2737)},
      {'icon': Icons.phone_android, 'label': 'GoPulsa', 'color': Color(0xff00AED6)},
      {'icon': Icons.clean_hands, 'label': 'GoClean', 'color': Color(0xff00AA13)},
      {'icon': Icons.more_horiz, 'label': 'Lainnya', 'color': Colors.grey},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service['label'] as String,
                style: TextStyle(
                  fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildXPCard(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[700]!, Colors.purple[900]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.stars, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '127 XP to your next treasure',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: const Text(
            'Akses cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            children: [
              _quickAccessCard('🏠', 'Rumah', 'Jl. Sudirman No. 123'),
              const SizedBox(width: 12),
              _quickAccessCard('🏢', 'Kantor', 'Gedung BCA Tower'),
              const SizedBox(width: 12),
              _quickAccessCard('📍', 'Gym', 'Sport Center Mall'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickAccessCard(String emoji, String title, String address) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Promo spesial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat semua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            children: [
              _promoCard(
                'assets/promo1.jpg',
                'Diskon 50% GoFood',
                'Berlaku hingga 31 Des',
                Colors.red,
              ),
              const SizedBox(width: 12),
              _promoCard(
                'assets/promo2.jpg',
                'Gratis ongkir GoSend',
                'Min. pembelian 50rb',
                Colors.green,
              ),
              const SizedBox(width: 12),
              _promoCard(
                'assets/promo3.jpg',
                'Cashback 20% GoPay',
                'Bayar pakai GoPay',
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _promoCard(String image, String title, String subtitle, Color color) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(Icons.local_offer, size: 60, color: color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromosPage extends StatelessWidget {
  const PromosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promos'),
        backgroundColor: const Color(0xff00AA13),
      ),
      body: const Center(
        child: Text('Halaman Promos', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: const Color(0xff00AA13),
      ),
      body: const Center(
        child: Text('Halaman Orders', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xff00AA13),
      ),
      body: const Center(
        child: Text('Halaman Chat', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

