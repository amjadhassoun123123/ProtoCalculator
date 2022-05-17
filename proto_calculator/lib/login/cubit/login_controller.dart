import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../calculate/view/calculator_page.dart';

class LoginController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String name = "";
  String email = "";
  String iconUrl = "";
  String uid = "";

  void signInWithGoogle(context) async {
    name = "";
    email = "";
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    _firebaseAuth.currentUser!;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CalculatorPage()));

    name = _googleSignIn.currentUser!.displayName!;
    email = _googleSignIn.currentUser!.email;
    iconUrl = _googleSignIn.currentUser!.photoUrl!;
    uid = _firebaseAuth.currentUser!.uid;
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void signInWithApple(BuildContext context) async {
    name = "";
    email = "";
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    await _firebaseAuth.signInWithCredential(oauthCredential);
    _firebaseAuth.currentUser!;
    // return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CalculatorPage()));

    if (_firebaseAuth.currentUser!.displayName != null) {
      name = _firebaseAuth.currentUser!.displayName!;
    }

    email = _firebaseAuth.currentUser!.email!;
    uid = _firebaseAuth.currentUser!.uid;
  }

  void signOut() async {
    Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
    name = "";
    email = "";
  }
}
