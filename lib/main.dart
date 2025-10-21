import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // tambahkan
import 'package:intl/intl.dart'; // tambahkan
import 'package:keuanganku/halamandepan/halamandepan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 Tambahkan ini untuk menghindari LocaleDataException
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lewati Onboarding',
      theme: ThemeData.dark(),
      home: Halamanpertama(),
      debugShowCheckedModeBanner: false,
    );
  }
}
