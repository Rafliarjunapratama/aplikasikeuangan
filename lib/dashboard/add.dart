import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String category = 'Lainnya';
  double amount = 0;
  bool isIncome = false;
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Gaji',
    'Makanan & Minuman',
    'Transportasi',
    'Tagihan',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Investasi',
    'Hadiah',
    'Donasi',
    'Pajak',
    'Lainnya',
  ];

  // ANIMATION CONTROLLERS
  late AnimationController _pageController;
  late AnimationController _toggleController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _toggleAnimation;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    // PAGE ENTRANCE ANIMATION
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Geser naik halus (tanpa mantul)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

// Hapus scale bounce → cukup fade aja
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_pageController); // Tidak berubah ukuran

    // EXISTING CONTROLLERS
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.elasticOut,
      ),
    );

    // START PAGE ANIMATION
    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _toggleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _onToggleChanged(bool value) {
    setState(() => isIncome = value);
    _toggleController.animateTo(isIncome ? 1 : 0);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            surface: Color(0xff101413),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xff1a1f1d),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate);
    final buttonColor = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
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
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAnimatedHeader(),
                            const SizedBox(height: 20),
                            Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: buttonColor.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      color: buttonColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Kembali',
                    style: TextStyle(
                      color: buttonColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
                            const SizedBox(height: 30),
                            _buildAnimatedToggleSection(buttonColor),
                            const SizedBox(height: 30),
                            _buildAnimatedTextField(
                              delay: 0.1,
                              icon: Icons.title_outlined,
                              label: 'Judul Transaksi',
                              controller: TextEditingController(text: title),
                              onChanged: (v) => title = v,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Masukkan judul' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildAnimatedTextField(
                              delay: 0.2,
                              icon: Icons.attach_money_outlined,
                              label: 'Jumlah (Rp)',
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                  text: amount == 0
                                      ? ''
                                      : amount.toStringAsFixed(0)),
                              onChanged: (v) => amount =
                                  double.tryParse(v.replaceAll('.', '')) ?? 0,
                              validator: (v) {
                                if (v?.isEmpty ?? true) {
                                  return 'Masukkan jumlah';
                                }
                                if (double.tryParse(
                                        v?.replaceAll('.', '') ?? '') ==
                                    null) {
                                  return 'Angka tidak valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildAnimatedCategorySection(delay: 0.3),
                            const SizedBox(height: 20),
                            _buildAnimatedDateField(formattedDate, delay: 0.4),
                            const SizedBox(height: 40),
                            _buildAnimatedSaveButton(buttonColor, delay: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  

  // --- ANIMASI BUILDER ---
  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final progress = _pageController.value;
        return Transform.translate(
          offset: Offset(0, 50 * (1 - progress)),
          child: Opacity(
            opacity: progress,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.tealAccent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaksi Baru',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      Text('Tambah Keuangan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedToggleSection(Color buttonColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child:
              Opacity(opacity: value, child: _buildToggleSection(buttonColor)),
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required double delay,
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 200).round()),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
              opacity: value,
              child: _buildTextField(
                  icon: icon,
                  label: label,
                  controller: controller,
                  onChanged: onChanged,
                  validator: validator,
                  keyboardType: keyboardType)),
        );
      },
    );
  }

  Widget _buildAnimatedCategorySection({required double delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 200).round()),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: _buildCategorySection()),
        );
      },
    );
  }

  Widget _buildAnimatedDateField(String formattedDate,
      {required double delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 200).round()),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: _buildDateField(formattedDate)),
        );
      },
    );
  }

  Widget _buildAnimatedSaveButton(Color buttonColor, {required double delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (delay * 200).round()),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildSaveButton(buttonColor),
          ),
        );
      },
    );
  }

  // --- BAGIAN UI ---
  Widget _buildToggleSection(Color buttonColor) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          
          const SizedBox(height: 8),
          const Text('Jenis Transaksi',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 16),
          Stack(
  alignment: Alignment.topLeft,
  children: [
    LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2; // lebar separuh
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.3),
                    Colors.transparent
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _toggleAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(halfWidth * _toggleAnimation.value, 0),
                  child: Container(
                    width: halfWidth, // otomatis setengah dari total
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        buttonColor.withOpacity(0.2),
                        Colors.transparent
                      ]),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: buttonColor.withOpacity(0.5)),
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onToggleChanged(false),
                    child: Container(
                      height: 60,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.arrow_downward,
                              color: Colors.red, size: 24),
                          SizedBox(height: 4),
                          Text('Pengeluaran',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onToggleChanged(true),
                    child: Container(
                      height: 60,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.arrow_upward,
                              color: Colors.green, size: 24),
                          SizedBox(height: 4),
                          Text('Pemasukan',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  ],
),

        ],
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: category,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
              dropdownColor: const Color(0xff1a1f1d),
              style: const TextStyle(color: Colors.white),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String formattedDate) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_outlined, color: Colors.teal),
            const SizedBox(width: 16),
             Flexible(
      child: Text(formattedDate,
                style: const TextStyle(color: Colors.white, fontSize: 16),  overflow: TextOverflow.ellipsis, // ✅ teks panjang jadi '…'
        maxLines: 1,)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Color buttonColor) {
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: GestureDetector(
            onTapDown: (_) => _buttonController.forward(),
            onTapUp: (_) => _buttonController.reverse(),
            onTap: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'title': title,
                  'category': category,
                  'amount': amount,
                  'isIncome': isIncome,
                  'date':
                      DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [buttonColor, buttonColor.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: buttonColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Simpan Transaksi',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
