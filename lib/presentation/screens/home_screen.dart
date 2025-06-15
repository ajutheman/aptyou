import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/bloc/auth_bloc.dart';
import '../../logic/auth/bloc/auth_state.dart';
import '../../data/repositories/content_repository.dart';
import '../../logic/auth/content/content_bloc.dart';
import '../../logic/auth/content/content_event.dart';
import '../../logic/auth/content/content_state.dart';
import 'package:aptyou/presentation/screens/game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: Text("🔒 Please sign in to continue"));
          }

          return BlocProvider(
            create: (_) => ContentBloc(ContentRepository())
              ..add(LoadContent(accessToken: authState.accessToken)),
            child: BlocBuilder<ContentBloc, ContentState>(
              builder: (context, contentState) {
                if (contentState is ContentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (contentState is ContentError) {
                  return Center(child: Text("❌ ${contentState.message}"));
                } else if (contentState is ContentLoaded) {
                  final content = contentState.content;
                  final topic = content.topics.first;
                  final script = topic.scriptTags.first;

                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(content.backgroundAssetUrl),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // T and t display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _letterCard('T'),
                                const SizedBox(width: 20),
                                _letterCard('t'),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Title
                            Text(
                              content.lessonName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 2),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              topic.topicName,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 40),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GameScreen(script: script),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                script.buttonText,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _letterCard(String letter) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
