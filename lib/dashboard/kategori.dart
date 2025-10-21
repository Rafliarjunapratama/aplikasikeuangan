import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> transactions = [];
  Map<String, CategoryData> categoriesData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTransactions = prefs.getString('transactions');

    if (savedTransactions != null) {
      setState(() {
        transactions =
            List<Map<String, dynamic>>.from(jsonDecode(savedTransactions));
        _processCategories();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _processCategories() {
    categoriesData.clear();

    for (var transaction in transactions) {
      final category = transaction['category'] as String;
      final amount = transaction['amount'] as double;
      final isIncome = transaction['isIncome'] as bool;

      if (!categoriesData.containsKey(category)) {
        categoriesData[category] = CategoryData(
          name: category,
          totalAmount: 0,
          transactionCount: 0,
          isIncome: isIncome,
        );
      }

      categoriesData[category]!.totalAmount += amount;
      categoriesData[category]!.transactionCount += 1;
    }
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Makanan': Colors.orange,
      'Transport': Colors.blue,
      'Belanja': Colors.purple,
      'Hiburan': Colors.pink,
      'Kesehatan': Colors.red,
      'Pendidikan': Colors.indigo,
      'Tagihan': Colors.brown,
      'Lainnya': Colors.grey,
      'Gaji': Colors.teal,
      'Bonus': Colors.green,
      'Investasi': Colors.amber,
      'Pemasukan Awal': Colors.tealAccent,
      'Flazz NFC': Colors.cyan,
    };
    return colors[category] ?? Colors.blueGrey;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Makanan': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Belanja': Icons.shopping_bag,
      'Hiburan': Icons.movie,
      'Kesehatan': Icons.local_hospital,
      'Pendidikan': Icons.school,
      'Tagihan': Icons.receipt_long,
      'Lainnya': Icons.more_horiz,
      'Gaji': Icons.account_balance_wallet,
      'Bonus': Icons.card_giftcard,
      'Investasi': Icons.trending_up,
      'Pemasukan Awal': Icons.account_balance,
      'Flazz NFC': Icons.nfc,
    };
    return icons[category] ?? Icons.category;
  }

  void _showCategoryDetail(String categoryName, CategoryData data) {
    final categoryTransactions =
        transactions.where((t) => t['category'] == categoryName).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff1a1f1d),
              const Color(0xff101413),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(categoryName).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoryName),
                      color: _getCategoryColor(categoryName),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${data.transactionCount} transaksi',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###').format(data.totalAmount)}',
                    style: TextStyle(
                      color: data.isIncome ? Colors.teal : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Transaction list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: categoryTransactions.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withOpacity(0.1),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final transaction = categoryTransactions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: transaction['isIncome']
                            ? Colors.teal.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaction['isIncome']
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color:
                            transaction['isIncome'] ? Colors.teal : Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transaction['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      transaction['date'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      '${transaction['isIncome'] ? '+' : '-'} Rp ${NumberFormat('#,###').format(transaction['amount'])}',
                      style: TextStyle(
                        color:
                            transaction['isIncome'] ? Colors.teal : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = categoriesData.entries.toList()
      ..sort((a, b) => b.value.totalAmount.compareTo(a.value.totalAmount));

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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
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
                            Icons.category,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategori',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Lihat pengeluaran per kategori',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Category list
                  Expanded(
                    child: categoriesData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.category_outlined,
                                    color: Colors.white70,
                                    size: 60,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Belum ada kategori',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah transaksi untuk melihat kategori',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: sortedCategories.length,
                            itemBuilder: (context, index) {
                              final entry = sortedCategories[index];
                              final categoryName = entry.key;
                              final categoryData = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: () => _showCategoryDetail(
                                      categoryName, categoryData),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.05),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                _getCategoryColor(categoryName)
                                                    .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(categoryName),
                                            color:
                                                _getCategoryColor(categoryName),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categoryName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${categoryData.transactionCount} transaksi',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Rp ${NumberFormat('#,###').format(categoryData.totalAmount)}',
                                              style: TextStyle(
                                                color: categoryData.isIncome
                                                    ? Colors.teal
                                                    : Colors.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.white54,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CategoryData {
  String name;
  double totalAmount;
  int transactionCount;
  bool isIncome;

  CategoryData({
    required this.name,
    required this.totalAmount,
    required this.transactionCount,
    required this.isIncome,
  });
}
