// import 'package:equatable/equatable.dart';
//
// abstract class ContentEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class LoadContentAssets extends ContentEvent {
//   final String accessToken;
//
//   LoadContentAssets(this.accessToken);
//
//   @override
//   List<Object?> get props => [accessToken];
// }
abstract class ContentEvent {}

class LoadContent extends ContentEvent {
  final String accessToken;

  LoadContent({required this.accessToken});
}
