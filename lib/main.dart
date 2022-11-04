import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pensieve/pensieve_model.dart';
import 'package:provider/provider.dart';

import 'pensieve_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pensieve ...',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: ChangeNotifierProvider(
        create: (_) => PensieveModel(storage: const FlutterSecureStorage()),
        child: const PensievePage(title: 'Pensieve ...'),
      ),
    );
  }
}
