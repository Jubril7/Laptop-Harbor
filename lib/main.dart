import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbor/features/app/start_screen/start_screen.dart';
import 'package:laptop_harbor/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laptop_harbor/cartProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDLT9JYs4etKsKApQu-1iEUbKWOSv91PCw",
        appId: "1:901233541093:web:9271451ba5170995e7390c",
        messagingSenderId: "901233541093",
        projectId: "laptop-harbour-69c9e",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartScreen(
          child: LoginPage(),
        ),
        
      ),
    );
  }
}
