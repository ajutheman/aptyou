import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/bloc/auth_bloc.dart';
import '../../logic/auth/bloc/auth_event.dart';
import '../../logic/auth/bloc/auth_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            print("Navigating to HomeScreen");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is AuthFailure) {
            print("Login failed: ${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(

              SnackBar(content: Text("Login failed: ${state.message}")),

            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignInWithGoogle());

              },
              child: const Text("Sign in with Google"),
            ),
          );
        },
      ),
    );
  }
}
