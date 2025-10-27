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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff1a1f1d), Color(0xff101413)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView( // <-- scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.transactionCount} transaksi',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rp ${NumberFormat('#,###').format(data.totalAmount)}',
                      style: TextStyle(
                        color: data.isIncome ? Colors.teal : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: categoryTransactions.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.1),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = categoryTransactions[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
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
                              color: transaction['isIncome']
                                  ? Colors.teal
                                  : Colors.red,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            transaction['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            transaction['date'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Text(
                              '${transaction['isIncome'] ? '+' : '-'} Rp ${NumberFormat('#,###').format(transaction['amount'])}',
                              style: TextStyle(
                                color: transaction['isIncome']
                                    ? Colors.teal
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
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


  @override
  Widget build(BuildContext context) {
    final sortedCategories = categoriesData.entries.toList()
      ..sort((a, b) => b.value.totalAmount.compareTo(a.value.totalAmount));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff101413), Color(0xff1a1f1d), Color(0xff0f1412)],
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
            : Column(
                children: [
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kategori',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Lihat pengeluaran per kategori',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: categoriesData.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
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
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32),
                                      child: Text(
                                        'Tambah transaksi untuk melihat kategori',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Jika lebar kurang dari 350px, gunakan Column
                                        if (constraints.maxWidth < 350) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: _getCategoryColor(
                                                              categoryName)
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Icon(
                                                      _getCategoryIcon(
                                                          categoryName),
                                                      color: _getCategoryColor(
                                                          categoryName),
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          categoryName,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '${categoryData.transactionCount} transaksi',
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Rp ${NumberFormat('#,###').format(categoryData.totalAmount)}',
                                                      style: TextStyle(
                                                        color: categoryData
                                                                .isIncome
                                                            ? Colors.teal
                                                            : Colors.red,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.white54,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }

                                        // Jika lebar cukup, gunakan Row seperti biasa
                                        return Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(
                                                        categoryName)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                _getCategoryIcon(categoryName),
                                                color: _getCategoryColor(
                                                    categoryName),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${categoryData.transactionCount} transaksi',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              child: Column(
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.right,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.white54,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
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