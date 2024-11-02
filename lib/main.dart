import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkloop/bottomnavbar.dart';
import 'package:talkloop/provider/auth_provider.dart';
import 'package:talkloop/provider/chat_provider.dart';
import 'package:talkloop/firebase_options.dart';
import 'package:talkloop/screens/login_screen.dart';
import 'package:talkloop/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=>AuthProvider()),
       ChangeNotifierProvider(create: (_)=>ChatProvider()),
    ],
    child: const MaterialApp
    (home:SplashScreen() ,
    debugShowCheckedModeBanner: false,),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context,authProvider,child){
   if(authProvider.isSignedIn){
    return  BottomNavBar();
   }else{
    return const LoginScreen();
   }
    });
  }
}