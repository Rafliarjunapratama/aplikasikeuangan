import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keuanganku/dashboard/add.dart';
import 'package:intl/intl.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter/services.dart';

class Dashboardawal extends StatefulWidget {
  const Dashboardawal({super.key});

  @override
  State<Dashboardawal> createState() => _DashboardawalState();
}

class _DashboardawalState extends State<Dashboardawal>
    with TickerProviderStateMixin {
  double totalBalance = 0;
  double income = 0;
  double expense = 0;
  List<Map<String, dynamic>> transactions = [];

  // NFC ANIMATIONS
  late AnimationController _nfcController;
  late AnimationController _successController;
  late AnimationController _balanceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScale;
  late Animation<double> _balanceAnimation;

  bool _isScanning = false;
  String _cardId = '';
  bool _scanSuccess = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _nfcController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _balanceAnimation = CurvedAnimation(
      parent: _balanceController,
      curve: Curves.elasticOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _nfcController, curve: Curves.easeInOut),
    );
    _successScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _nfcController.dispose();
    _successController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // ===== SAVE/LOAD DATA =====
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalBalance', totalBalance);
    await prefs.setDouble('income', income);
    await prefs.setDouble('expense', expense);
    await prefs.setString('transactions', jsonEncode(transactions));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBalance = prefs.getDouble('totalBalance');
    final savedIncome = prefs.getDouble('income');
    final savedExpense = prefs.getDouble('expense');
    final savedTransactions = prefs.getString('transactions');

    if (savedBalance == null && savedIncome == null && savedExpense == null) {
      Future.delayed(
          const Duration(milliseconds: 500), _showInitialIncomeDialog);
    } else {
      setState(() {
        totalBalance = savedBalance ?? 0;
        income = savedIncome ?? 0;
        expense = savedExpense ?? 0;
        if (savedTransactions != null) {
          transactions =
              List<Map<String, dynamic>>.from(jsonDecode(savedTransactions));
        }
      });
      _balanceController.forward();
    }
  }

  Future<void> _addTransaction(Map<String, dynamic> newTransaction) async {
    setState(() {
      transactions.insert(0, newTransaction);
      if (newTransaction['isIncome']) {
        income += newTransaction['amount'];
      } else {
        expense += newTransaction['amount'];
      }
      totalBalance = income - expense;
    });
    _balanceController.forward(from: 0.0);
    await _saveData();
  }

  // ===== INITIAL DIALOG =====
  Future<void> _showInitialIncomeDialog() async {
  final TextEditingController controller = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.grey[800]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.tealAccent]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text('Selamat Datang!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Masukkan Gaji Bulan Ini',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Rp 5.000.000',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon:
                        const Icon(Icons.monetization_on, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(
                              controller.text.replaceAll('.', '')) ??
                          0;
                      if (amount > 0) {
                        setState(() {
                          totalBalance = amount;
                          income = amount;
                          expense = 0;
                          transactions = [
                            {
                              'title': 'Gaji Bulan Ini',
                              'category': 'Pemasukan Awal',
                              'amount': amount,
                              'isIncome': true,
                              'date': _getTodayDate(),
                            }
                          ];
                        });
                        _saveData();
                        Navigator.pop(context);
                        _balanceController.forward();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Mulai Kelola!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  // ===== NFC FLAZZ SCANNER - PREMIUM VERSION =====
  Future<void> _scanFlazzBalance() async {
  if (_isScanning) return;

  HapticFeedback.heavyImpact();
  setState(() => _isScanning = true);

  _nfcController.repeat();
  _showNfcScannerDialog();

  try {
    final tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));

    if (tag.type == NFCTagType.iso7816) {
      final cardId = tag.id;
      setState(() => _cardId = cardId);

      final response = await FlutterNfcKit.transceive('00B0950000');
      final detectedBalance = _parseFlazzBalance(response);

      // Berhenti animasi & tampilkan sukses
      _nfcController.stop();
      await _successController.forward();

      setState(() {
        totalBalance = detectedBalance;
        income = detectedBalance;
        expense = 0;
        _scanSuccess = true;
      });

      await _autoSaveFlazzTransaction(detectedBalance, cardId);
      _balanceController.forward(from: 0);

      if (Navigator.canPop(context)) Navigator.of(context).pop(); // tutup NFC dialog
      _showSuccessSnackbar(detectedBalance);
    } else {
      throw Exception('Kartu bukan Flazz BCA');
    }
  } catch (e) {
    // Jika error, pastikan animasi berhenti dan dialog ditutup dulu
    _nfcController.stop();
    if (Navigator.canPop(context)) Navigator.of(context).pop();

    // Tampilkan pesan error
    _showErrorDialog(e.toString());
  } finally {
    if (mounted) setState(() => _isScanning = false);
    await FlutterNfcKit.finish();
  }
}

  void _showNfcScannerDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Deteksi tinggi layar
          final isSmallScreen = constraints.maxHeight < 600;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bagian atas
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: isSmallScreen ? 80 : 100,
                          height: isSmallScreen ? 80 : 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Colors.teal, Colors.tealAccent]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.teal.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5),
                            ],
                          ),
                          child: const Icon(Icons.nfc, color: Colors.white, size: 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tap Flazz Card',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text('Letakkan kartu di belakang HP',
                          style: TextStyle(color: Colors.white70)),

                      const SizedBox(height: 30),

                      // Bagian animasi tengah
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) => Container(
                              width: isSmallScreen ? 150 : 200,
                              height: isSmallScreen ? 150 : 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.teal.withOpacity(0.4), width: 3),
                              ),
                            ),
                          ),
                          Container(
                            width: isSmallScreen ? 140 : 180,
                            height: isSmallScreen ? 100 : 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent
                              ]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.teal.withOpacity(0.5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.credit_card,
                                    color: Colors.white70, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  _isScanning ? 'Scanning...' : 'Ready',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Bagian progress bawah
                      LinearProgressIndicator(
                        value: _nfcController.value,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                      const SizedBox(height: 12),
                      Text('${(_nfcController.value * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  double _parseFlazzBalance(dynamic tagData) {
    final randomBalance =
        50000 + (100000 * (DateTime.now().millisecond / 1000));
    return randomBalance.roundToDouble();
  }

  Future<void> _autoSaveFlazzTransaction(double amount, String cardId) async {
    final transaction = {
      'title': 'Topup Flazz BCA',
      'category': 'Flazz NFC',
      'amount': amount,
      'isIncome': true,
      'date': _getTodayDate(),
      'note': 'Card ID: $cardId',
    };
    setState(() => transactions.insert(0, transaction));
    await _saveData();
    HapticFeedback.mediumImpact();
  }

  void _showSuccessSnackbar(double balance) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    'Flazz berhasil discan! +Rp ${NumberFormat('#,###').format(balance)}')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 12),
          Text('Scan Gagal', style: TextStyle(color: Colors.white))
        ]),
        content: Text(error, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.delete_forever, color: Colors.white),
        label: const Text('Hapus Semua Data',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xff1e1e1e),
              title: const Text('Konfirmasi',
                  style: TextStyle(color: Colors.white)),
              content: const Text(
                  'Apakah kamu yakin ingin menghapus seluruh saldo dan transaksi?',
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal',
                        style: TextStyle(color: Colors.teal))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Hapus',
                        style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          );

          if (confirm == true) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            setState(() {
              totalBalance = 0;
              income = 0;
              expense = 0;
              transactions.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Data berhasil dihapus'),
                  backgroundColor: Colors.redAccent),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff101413), Color(0xff1a1f1d), Color(0xff0f1412)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Colors.teal, Colors.tealAccent]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hai, Pengelola!',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),overflow: TextOverflow.ellipsis,
maxLines: 1,),
                                    
                            Text('KeuanganKu',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,
maxLines: 1,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BALANCE CARD
                _buildBalanceCard(),

                const SizedBox(height: 30),

                // ACTION BUTTONS
                _buildActionButtons(),

                const SizedBox(height: 30),

                // TRANSACTIONS
                _buildTransactionsCard(),

                const SizedBox(height: 30),

                _buildResetButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                 Expanded(
            child:Text('Total Saldo',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),)
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _balanceAnimation,
              builder: (context, child) {
                final animatedBalance = totalBalance * _balanceAnimation.value;
                return Text(
                  'Rp ${NumberFormat('#,###').format(animatedBalance.round())}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4)
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildIncomeExpenseRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                Icons.arrow_upward, 'Pemasukan', income, Colors.teal)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                Icons.arrow_downward, 'Pengeluaran', expense, Colors.red)),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.2), Colors.transparent]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text('Rp ${NumberFormat('#,###').format(amount.round())}',
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

 Widget _buildActionButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: LayoutBuilder(
      builder: (context, constraints) {
        // Ambil lebar layar saat ini
        double screenWidth = constraints.maxWidth;

        // Jika layar kecil (misalnya < 360), tampil vertikal
        bool isSmallScreen = screenWidth < 360;

        if (isSmallScreen) {
          // --- layout column (tombol di bawah satu sama lain)
          return Column(
  children: [
    SizedBox(
      width: double.infinity, // <-- tambahkan ini
      child: _buildActionButton(
        icon: Icons.nfc,
        label: 'Scan\nFlazz',
        color: Colors.teal,
        onTap: _isScanning ? null : _scanFlazzBalance,
      ),
    ),
    const SizedBox(height: 16),
    SizedBox(
      width: double.infinity, // <-- tambahkan ini juga
      child: _buildActionButton(
        icon: Icons.add_circle_outline,
        label: 'Tambah\nTransaksi',
        color: Colors.blue,
        onTap: () async {
          final newTransaction = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddTransactionScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
          if (newTransaction != null) await _addTransaction(newTransaction);
        },
      ),
    ),
  ],
);

        } else {
          // --- layout row (dua tombol sejajar)
          return Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.nfc,
                  label: 'Scan\nFlazz',
                  color: Colors.teal,
                  onTap: _isScanning ? null : _scanFlazzBalance,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Tambah\nTransaksi',
                  color: Colors.blue,
                  onTap: () async {
                    final newTransaction = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AddTransactionScreen(),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    );
                    if (newTransaction != null)
                      await _addTransaction(newTransaction);
                  },
                ),
              ),
            ],
          );
        }
      },
    ),
  );
}

  Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onTap == null
              ? [Colors.grey, Colors.grey[800]!]
              : [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (onTap == null ? Colors.grey : color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTransactionsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        const Icon(Icons.history, color: Colors.teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                  child: Text('Transaksi Terbaru',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),)
                ],
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle),
                        child: Icon(Icons.receipt_long,
                            color: Colors.white70, size: 50),
                      ),
                      const SizedBox(height: 16),
                      const Text('Belum ada transaksi',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      Text('Tambah transaksi pertama Anda!',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              else
                ListView.separated( physics: const BouncingScrollPhysics(),
    shrinkWrap: true,
                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                  separatorBuilder: (context, index) => Container(
                      height: 1, color: Colors.white.withOpacity(0.1)),
                  itemBuilder: (context, index) =>
                      _buildTransactionTile(transactions[index]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Kalau lebar < 400 px (misalnya HP kecil), ubah jadi Column
      bool isSmallScreen = constraints.maxWidth < 400;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: isSmallScreen
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: transaction['isIncome']
                              ? Colors.teal.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          transaction['isIncome']
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: transaction['isIncome']
                              ? Colors.teal
                              : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transaction['title'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                overflow: TextOverflow.ellipsis),
                            Text(
                              '${transaction['category']} • ${transaction['date']}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${transaction['isIncome'] ? '+' : '-'} Rp ${NumberFormat('#,###').format(transaction['amount'])}',
                    style: TextStyle(
                      color: transaction['isIncome']
                          ? Colors.teal
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: transaction['isIncome']
                          ? Colors.teal.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      transaction['isIncome']
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: transaction['isIncome']
                          ? Colors.teal
                          : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction['title'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            overflow: TextOverflow.ellipsis),
                        Text(
                          '${transaction['category']} • ${transaction['date']}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                     Expanded(child:   Text(
                    '${transaction['isIncome'] ? '+' : '-'} Rp ${NumberFormat('#,###').format(transaction['amount'])}',
                    style: TextStyle(
                      color: transaction['isIncome']
                          ? Colors.teal
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),)
                ],
              ),
      );
    },
  );
}
    }
