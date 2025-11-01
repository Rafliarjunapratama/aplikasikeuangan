import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {
  double income = 0;
  double expense = 0;
  List<Map<String, dynamic>> transactions = [];
  bool loading = true;

  late AnimationController _animationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    );
    _loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      income = prefs.getDouble('income') ?? 0;
      expense = prefs.getDouble('expense') ?? 0;
      final txString = prefs.getString('transactions');
      if (txString != null) {
        try {
          final decoded = jsonDecode(txString) as List<dynamic>;
          transactions =
              decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {
          transactions = [];
        }
      }
      loading = false;
    });
    _animationController.forward();
  }

  List<Map<String, dynamic>> get _lastSixTransactions =>
      transactions.take(6).toList();

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
          child: loading
              ? _buildLoadingSkeleton()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildOverviewCard(),
                      const SizedBox(height: 24),
                      _buildDonutChartCard(),
                      const SizedBox(height: 24),
                     
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics',
                  style: TextStyle(color: Colors.white70, fontSize: 16),overflow: TextOverflow.ellipsis,),
              Text('Statistik Keuangan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  

  Widget _buildOverviewCard() {
  final balance = income - expense;
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)
      ],
    ),
    child: Column(
      children: [
        const Text('Ringkasan Bulan Ini',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: _buildStatItem(
                    Icons.arrow_upward, 'Pemasukan', income, Colors.teal)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatItem(Icons.arrow_downward, 'Pengeluaran',
                    expense, Colors.red)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              balance >= 0 ? Colors.green : Colors.red,
              Colors.transparent
            ]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 20),
              const SizedBox(width: 3),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.black87,
                        title: const Text('Saldo Kamu',
                            style: TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                        content: Text(
                          'Rp ${NumberFormat('#,###').format(balance.abs())}',
                          style: const TextStyle(
                              color: Colors.tealAccent, fontSize: 20),
                      
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Saldo: Rp ${NumberFormat('#,###').format(balance.abs())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
               Expanded(
                child:Text(balance >= 0 ? ' ✅' : ' ❌',
                  style: const TextStyle(color: Colors.white, fontSize: 18),     overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,),)
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStatItem(
      IconData icon, String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.2), Colors.transparent]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text('Rp ${NumberFormat('#,###').format(amount.round())}',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard() {
    if (income == 0 && expense == 0) {
      return _buildEmptyChart(
          'Belum ada data keuangan', Icons.analytics_outlined);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)
        ],
      ),
      child: Column(
        children: [
          const Text('Distribusi Keuangan',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _createAnimatedPieSections(animValue),
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    borderData: FlBorderData(show: false),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeOut,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // ✅ FIX: Wrap legend dengan Row dan Expanded
          Row(
            children: [
              Expanded(
                child: _buildLegend(Colors.greenAccent, 'Pemasukan', income),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLegend(Colors.redAccent, 'Pengeluaran', expense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createAnimatedPieSections(double animValue) {
    final total = income + expense;
    final incomePercent = total == 0 ? 0 : (income / total) * 100;
    final expensePercent = total == 0 ? 0 : (expense / total) * 100;

    return [
      PieChartSectionData(
        value: income == 0 ? 0.001 : income * animValue,
        title: '${(incomePercent * animValue).toStringAsFixed(0)}%',
        color: Colors.greenAccent,
        radius: 70,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: expense == 0 ? 0.001 : expense * animValue,
        title: '${(expensePercent * animValue).toStringAsFixed(0)}%',
        color: Colors.redAccent,
        radius: 70,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ];
  }

 

  Widget _buildEmptyChart(String text, IconData icon) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 60),
          const SizedBox(height: 16),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  double _computeMaxY() {
    if (_lastSixTransactions.isEmpty) return 100;
    final max = _lastSixTransactions
        .map((t) => (t['amount'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return (max * 1.2).clamp(100, double.infinity);
  }

  // ✅ FIX: Legend dengan layout yang lebih baik
  Widget _buildLegend(Color color, String label, double amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Rp ${NumberFormat('#,###').format(amount.round())}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)
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
                  child: const Icon(Icons.receipt_long,
                      color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                          child:Text('Transaksi Terbaru',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            ..._lastSixTransactions
                .map((tx) => _buildTransactionTile(tx))
                .toList(),
          ],
        ),
      ),
    );
  }

  // ✅ FIX: Transaction tile dengan proper overflow handling
  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final isIncome = transaction['isIncome'] as bool? ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green : Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${transaction['category']} • ${transaction['date']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
              Expanded(
                          child: Text(
            '${isIncome ? '+' : '-'} Rp ${NumberFormat('#,###').format(transaction['amount'])}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),)
        ],
      ),
    );
  }
}