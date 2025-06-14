// import 'package:equatable/equatable.dart';
//
// abstract class ContentState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class ContentInitial extends ContentState {}
//
// class ContentLoading extends ContentState {}
//
// class ContentLoaded extends ContentState {
//   final Map<String, dynamic> data;
//
//   ContentLoaded(this.data);
//
//   @override
//   List<Object?> get props => [data];
// }
//
// class ContentError extends ContentState {
//   final String message;
//
//   ContentError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
import '../../../data/models/content_model.dart';

abstract class ContentState {}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentLoaded extends ContentState {
  final ContentModel content;

  ContentLoaded({required this.content});
}

class ContentError extends ContentState {
  final String message;

  ContentError(this.message);
}
