// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'content_event.dart';
// import 'content_state.dart';
// import '../../../data/repositories/content_repository.dart';
//
// class ContentBloc extends Bloc<ContentEvent, ContentState> {
//   final ContentRepository contentRepository;
//
//   ContentBloc(this.contentRepository) : super(ContentInitial()) {
//     on<LoadContentAssets>(_onLoadContentAssets);
//   }
//
//   Future<void> _onLoadContentAssets(
//       LoadContentAssets event,
//       Emitter<ContentState> emit,
//       ) async {
//     emit(ContentLoading());
//     final data = await contentRepository.fetchAssets(event.accessToken);
//     if (data != null) {
//       emit(ContentLoaded(data));
//     } else {
//       emit(ContentError('Failed to load content.'));
//     }
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/content_repository.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository repository;

  ContentBloc(this.repository) : super(ContentInitial()) {
    on<LoadContent>((event, emit) async {
      emit(ContentLoading());

      try {
        final content = await repository.fetchContent(event.accessToken);
        emit(ContentLoaded(content: content));
      } catch (e) {
        emit(ContentError('Failed to load content'));
      }
    });
  }
}
