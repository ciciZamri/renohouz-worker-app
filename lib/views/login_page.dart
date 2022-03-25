import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:renohouz_worker/utils/debugger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage;
  bool isLoadingGoogle = false;

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoadingGoogle = true;
      errorMessage = null;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential cdn = await FirebaseAuth.instance.signInWithCredential(credential);
      //return await FirebaseAuth.instance.currentUser.linkWithCredential(credential);
    } catch (e) {
      Debugger.log(e);
      setState(() {
        errorMessage = 'Something wrong. Please try again.';
        isLoadingGoogle = false;
      });
    }
  }

  double get dividerWidth {
    double width = 0.0;
    width = MediaQuery.of(context).size.width / 2;
    width -= 16.0;
    return width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 128.0),
            const Text('Welcome to Renohouz',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
            const SizedBox(height: 96.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled) ? Colors.lightGreen[200] : Colors.lightGreen;
                }),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: const Image(
                        image: AssetImage('assets/google_icon.png'),
                        width: 28,
                        height: 28,
                        isAntiAlias: true,
                      ),
                    ),
                    const Spacer(),
                    const Text('Login with Google'),
                    const Spacer(),
                    const SizedBox(width: 42.0),
                  ],
                ),
              ),
              onPressed: isLoadingGoogle
                  ? null
                  : () async {
                      await signInWithGoogle();
                    },
            ),
            errorMessage == null
                ? const SizedBox(height: 0)
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(errorMessage ?? '', style: const TextStyle(fontSize: 13, color: Colors.red)),
                  ),
          ],
        ),
      ),
    );
  }
}
