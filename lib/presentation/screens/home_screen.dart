import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/bloc/auth_bloc.dart';
import '../../logic/auth/bloc/auth_state.dart';
// import '../../logic/content/bloc/content_bloc.dart';
// import '../../logic/content/bloc/content_event.dart';
// import '../../logic/content/bloc/content_state.dart';
import '../../data/repositories/content_repository.dart';
import '../../logic/auth/content/content_bloc.dart';
import '../../logic/auth/content/content_event.dart';
import '../../logic/auth/content/content_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AptYou Content")),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: Text("User not authenticated"));
          }

          return BlocProvider(
            create: (_) => ContentBloc(ContentRepository())
              ..add(LoadContent(accessToken: authState.accessToken)),
            child: BlocBuilder<ContentBloc, ContentState>(
              builder: (context, contentState) {
                if (contentState is ContentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (contentState is ContentLoaded) {
                  final topic = contentState.content.topics.first;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        Text(
                          "Lesson: ${contentState.content.lessonName}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(topic.topicName,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Image.network(contentState.content.backgroundAssetUrl),
                        const SizedBox(height: 16),
                        Text("Try tapping Capital and Small T!"),
                      ],
                    ),
                  );
                } else if (contentState is ContentError) {
                  return Center(child: Text("Error: ${contentState.message}"));
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
