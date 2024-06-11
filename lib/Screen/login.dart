import 'package:drive_assignment/Screen/home.dart';
import 'package:drive_assignment/secure_storage.dart';
import 'package:drive_assignment/shared/models/user_models.dart';
import 'package:drive_assignment/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: double.maxFinite,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            onPressed: () => signInWithGoogle(),
            child: Text(
              'LOGIN',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = await GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/drive',
        ],
      ).signIn();
      final GoogleSignInAccount? googleSignInAccount = googleSignIn;
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        await storeSecureStorage(user, credential.accessToken ?? "");

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
      // Use the user object for further operations or navigate to a new screen.
    } catch (e) {
      Utils.showFailureToast("Something went wrong. Please try again");
    }
  }

  Future<void> storeSecureStorage(User user, String accessToken) async {
    SecureStorageService? secureStorageService =
        SecureStorageService.getInstance();
    secureStorageService!.email = Future.value(user.email ?? "");
    secureStorageService.photoURL = Future.value(user.photoURL ?? "");
    secureStorageService.name = Future.value(user.displayName ?? "");
    secureStorageService.authToken = Future.value(accessToken);
    secureStorageService.refreshToken = Future.value(user.refreshToken ?? "");

    AppUser.email = user.email ?? "";
    AppUser.photoUrl = user.photoURL ?? "";
    AppUser.name = user.displayName ?? "";
    AppUser.isLoggedIn = true;
  }
}
