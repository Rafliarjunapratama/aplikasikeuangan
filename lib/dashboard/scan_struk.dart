import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _recognizedText = '';
  Map<String, String> _parsed = {};
  bool _isProcessing = false;

  late AnimationController _scanController;
  late AnimationController _successController;
  late Animation<double> _scanWave;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scanWave = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _successScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _takePhotoAndScan() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;

      setState(() {
        _isProcessing = true;
        _image = File(photo.path);
        _recognizedText = '';
        _parsed = {};
      });

      _scanController.repeat();
      await _performOcr(File(photo.path));
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isProcessing = false);
      _scanController.stop();
    }
  }

  // ===== TAMBAHAN: TAMPILAN STRUK SEPERTI NOTA ASLI =====
  Widget _buildReceiptPreview() {
    final lines =
        _recognizedText.split('\n').where((e) => e.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _parsed['merchant'] ?? 'NAMA TOKO',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              _parsed['date'] ??
                  DateFormat('dd MMM yyyy – HH:mm').format(DateTime.now()),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const Divider(thickness: 1, height: 24, color: Colors.black54),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(line,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
              )),
          const Divider(thickness: 1, height: 24, color: Colors.black54),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                _parsed['total'] != null ? 'Rp ${_parsed['total']}' : '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Payment: Debit BCA',
              style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Terima kasih telah berbelanja!',
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGalleryAndScan() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo == null) return;

    setState(() {
      _isProcessing = true;
      _image = File(photo.path);
      _recognizedText = '';
      _parsed = {};
    });

    _scanController.repeat();
    await _performOcr(File(photo.path));
  }

  Future<void> _performOcr(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      final StringBuffer buffer = StringBuffer();
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          buffer.writeln(line.text);
        }
      }

      final fullText = buffer.toString();
      setState(() => _recognizedText = fullText);

      final parsed = _parseReceiptText(fullText);
      setState(() => _parsed = parsed);

      _scanController.stop();
      _successController.forward();

      // Auto-hide success after 2s
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _successController.reverse();
      });
    } catch (e) {
      debugPrint('OCR error: $e');
    } finally {
      textRecognizer.close();
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Map<String, String> _parseReceiptText(String text) {
    final Map<String, String> out = {};
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Currency regex
    final currencyRegex =
        RegExp(r'((?:Rp\.?\s?)?[\d\.,]{2,})', caseSensitive: false);

    // Find TOTAL
    for (var i = lines.length - 1; i >= 0; i--) {
      final l = lines[i].toLowerCase();
      if (l.contains('total') || l.contains('jumlah') || l.contains('bayar')) {
        final m = currencyRegex.firstMatch(lines[i]);
        if (m != null) {
          out['total'] = _normalizeCurrencyString(m.group(0)!);
          break;
        }
        if (i + 1 < lines.length) {
          final m2 = currencyRegex.firstMatch(lines[i + 1]);
          if (m2 != null) {
            out['total'] = _normalizeCurrencyString(m2.group(0)!);
            break;
          }
        }
      }
    }

    // Find DATE
    final dateRegex = RegExp(
        r'\b(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}|\d{4}[\/\-]\d{1,2}[\/\-]\d{1,2})\b');
    final m = dateRegex.firstMatch(text);
    if (m != null) out['date'] = m.group(0)!;

    // Merchant
    if (lines.isNotEmpty) out['merchant'] = lines.first;

    out['full_text'] = text;
    return out;
  }

  String _normalizeCurrencyString(String s) {
    var t = s.replaceAll(RegExp(r'Rp\.?\s?', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'[^\d,\.]'), '');
    return t.trim();
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
  child: Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildActionButtons(),
        const SizedBox(height: 20),
        _buildContent(),
      ],
    ),
  ),
),

        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.tealAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.receipt_long, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Scanner',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                Text('Scan Struk Otomatis',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              color: Colors.teal,
              onTap: _takePhotoAndScan,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              color: Colors.blue,
              onTap: _pickFromGalleryAndScan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isProcessing) {
      return _buildScanningAnimation();
    }
    if (_parsed.isNotEmpty) {
      return _buildSuccessContent();
    }
    return _buildEmptyState();
  }

  Widget _buildScanningAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _scanWave,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.teal.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CustomPaint(
                      painter: WavePainter(_scanWave.value),
                      size: const Size(200, 200),
                    ),
                  );
                },
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long,
                    color: Colors.teal, size: 50),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Scanning...',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 10),
          Text('AI sedang membaca struk',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _successScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _successScale.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.green, Colors.greenAccent]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      const Text('SCAN SUKSES!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // PARSED RESULTS
          // PARSED RESULTS
          _buildParsedCard(),
          const SizedBox(height: 20),

// TAMPILAN STRUK ASLI
          _buildReceiptPreview(),
          const SizedBox(height: 20),

// SAVE BUTTON
          _buildSaveTransactionButton(),
          const SizedBox(height: 20),

// RAW TEXT
          _buildRecognizedTextCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, color: Colors.teal, size: 80),
          ),
          const SizedBox(height: 20),
          const Text('Scan struk pertama Anda!',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 10),
          Text('Ambil foto struk atau pilih dari galeri',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildParsedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.tealAccent]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.analytics, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Hasil AI Parsing',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _parsedItem(
              'store', Icons.store, _parsed['merchant'] ?? 'Tidak terdeteksi'),
          _parsedItem(
              'date', Icons.date_range, _parsed['date'] ?? 'Tidak terdeteksi'),
          _parsedItem(
              'amount',
              Icons.attach_money,
              _parsed['total'] != null
                  ? 'Rp ${_parsed['total']}'
                  : 'Tidak terdeteksi'),
        ],
      ),
    );
  }

  Widget _parsedItem(String type, IconData icon, String value) {
    final color = type == 'amount' ? Colors.green : Colors.teal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getLabel(type),
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(String type) => {
        'store': 'Merchant',
        'date': 'Tanggal',
        'amount': 'Total',
      }[type]!;

  Widget _buildSaveTransactionButton() {
    return AnimatedBuilder(
      animation: _successScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _successScale.value,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disimpan ke Transaksi! ✅')),
              );
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.green, Colors.greenAccent]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 12),
                    Text('SIMPAN KE TRANSAKSI',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecognizedTextCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.text_fields,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Raw OCR Text',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _recognizedText.isEmpty ? 'Belum ada teks' : _recognizedText,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WAVE ANIMATION PAINTER
class WavePainter extends CustomPainter {
  final double progress;
  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2 - 20) * progress;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
