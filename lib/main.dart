import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // superbase
  await Supabase.initialize(
    url: 'https://gyqgywpreuwynluadmhr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5cWd5d3ByZXV3eW5sdWFkbWhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MjU3NzYsImV4cCI6MjA3MDMwMTc3Nn0.dgNVTTAtBzawbatw2Io46RUFB-k3h8VDIgSgaeKF77o',
  );

  runApp(const App());
}
