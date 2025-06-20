import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'logic/auth/bloc/auth_bloc.dart';
import 'logic/auth/bloc/auth_event.dart';
import 'logic/auth/bloc/auth_state.dart';

import 'presentation/screens/login_screen.dart';
import 'presentation/screens/RiveDemo.dart';
// lib/presentation/screens/RiveDemo.dart
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/write_t_screen.dart'; // ✅ Make sure this file exists
import 'presentation/rive_demo/rive_demo_screen.dart';
import 'data/models/content_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optional: Get FCM Token if needed
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("✅ FCM Token: $fcmToken");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'AptYou',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          // '/home': (_) => const HomeScreen(),
          '/home': (_) => const RiveDemo(),
          '/login': (_) => const LoginScreen(),
          '/riveDemo': (_) => const RiveDemoScreen(),
          '/writeT': (_) => const WriteTScreen(), // ✅ Make sure class exists
          '/game': (context) {
            final script = ModalRoute.of(context)!.settings.arguments as ScriptTagModel;
            return GameScreen(script: script);
          },
        },
      ),
    );
  }
}
