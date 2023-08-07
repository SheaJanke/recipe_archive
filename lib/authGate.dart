import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_archive/pages/recipeListPage.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        User? user = snapshot.data;
        // User is not signed in
        if (user == null) {
          return const SignInScreen();
        }
        return KeyboardDismissOnTap(
          child: RecipeListPage(user: user),
        );
      },
    );
  }
}
