import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/providers/activity_provider.dart';
import 'package:renohouz_worker/providers/location_provider.dart';
import 'package:renohouz_worker/providers/search_history_provider.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/views/login_page.dart';
import 'package:renohouz_worker/views/register_page.dart';
import 'package:renohouz_worker/views/root_error_page.dart';
import 'package:renohouz_worker/views/shell.dart';
import 'package:renohouz_worker/views/upload_photo_page.dart';
import 'package:renohouz_worker/views/verify_phone_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
      ChangeNotifierProvider<LocationProvider>(create: (context) => LocationProvider()),
      ChangeNotifierProvider<ActivityProvider>(create: (context) => ActivityProvider()),
      ChangeNotifierProvider<SearchHistoryProvider>(create: (context) => SearchHistoryProvider()),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Renohouz',
      initialRoute: '/root',
      routes: {
        '/root': (context) => const Root(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        buttonTheme: ButtonThemeData(
          disabledColor: Colors.amber[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          height: 48.0,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              return states.contains(MaterialState.disabled) ? Colors.amber[200] : Colors.amber;
            }),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        ),
      ),
    );
  }
}

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      Navigator.popUntil(context, ModalRoute.withName('/root'));
      if (user == null) {
        Manager.restartApp();
      } else {
        //logged in
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          //Debugger.log("user found");
          return FutureBuilder(
            future: Manager.onStart(context.read<UserProvider>()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return RootErrorPage(onRetry: () => setState(() {}));
              }
              return ValueListenableBuilder(
                valueListenable: Manager.status,
                builder: (context, AppStatus status, _) {
                  if (status == AppStatus.toRegister) {
                    return const RegisterPage();
                  } else if (status == AppStatus.toUploadPhoto) {
                    return const UploadPhotoPage();
                  } else if (status == AppStatus.toVerifyPhoneNumber) {
                    return const PhoneVerification();
                  } else if (status == AppStatus.loading) {
                    return const Material(child: Center(child: CircularProgressIndicator()));
                  } else {
                    return const Shell();
                  }
                },
              );
            },
          );
        } else {
          Debugger.log("user not found");
          return const LoginPage();
        }
      },
    );
  }
}
