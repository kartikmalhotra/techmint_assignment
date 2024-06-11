import 'package:drive_assignment/Screen/login.dart';
import 'package:drive_assignment/secure_storage.dart';
import 'package:drive_assignment/shared/models/user_models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:drive_assignment/Screen/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    SecureStorageService? secureStorageService =
        SecureStorageService.getInstance();
    bool isUserLoggedIn =
        (await secureStorageService?.authToken)?.isNotEmpty ?? false;
    if (isUserLoggedIn) {
      AppUser.isLoggedIn = isUserLoggedIn;
      AppUser.email = (await secureStorageService?.email ?? "");
      AppUser.name = (await secureStorageService?.name ?? "");
      AppUser.photoUrl = (await secureStorageService?.photoURL ?? "");
    }
    runApp(MyApp(isUserLoggedIn: isUserLoggedIn));
  } catch (exe) {
    if (kDebugMode) {
      print("Exception: " + exe.toString());
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;

  const MyApp({super.key, required this.isUserLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Drive Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isUserLoggedIn
          ? const MyHomePage(title: 'Google Drive Demo')
          : const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
    );
  }
}
