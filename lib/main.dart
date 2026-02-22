import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vqpzfduxtdcqihjnisic.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxcHpmZHV4dGRjcWloam5pc2ljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3MDQwNjQsImV4cCI6MjA4NzI4MDA2NH0.NCZ25O8MhTUHQQEUBwHVlg5tO5ukRvajXHXXWpOOLRE',
  );

  // Initialize Hive
  await Hive.initFlutter();
  await LocalStorageService.init();

  runApp(const TheQuis());
}
