import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rafael_flutter/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyD3fWZp9HOcmCtweUsd1Kz4yAeJlMucul0",
            authDomain: "java-course-931bd.firebaseapp.com",
            projectId: "java-course-931bd",
            storageBucket: "java-course-931bd.firebasestorage.app",
            messagingSenderId: "373588985186",
            appId: "1:373588985186:web:05cf362e78b901539d583b",
            measurementId: "G-YK7WRK97CV"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const Wrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
