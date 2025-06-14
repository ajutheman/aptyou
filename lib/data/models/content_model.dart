class ContentModel {
  final String lessonName;
  final String lessonDescription;
  final String backgroundAssetUrl;
  final List<Topic> topics;

  ContentModel({
    required this.lessonName,
    required this.lessonDescription,
    required this.backgroundAssetUrl,
    required this.topics,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      lessonName: json['lessonName'],
      lessonDescription: json['lessonDescription'],
      backgroundAssetUrl: json['backgroundAssetUrl'],
      topics: (json['topics'] as List).map((e) => Topic.fromJson(e)).toList(),
    );
  }
}

class Topic {
  final String topicName;
  final List<String> correctCapitalAudios;
  final List<String> correctSmallAudios;
  final List<String> sampleWords;

  Topic({
    required this.topicName,
    required this.correctCapitalAudios,
    required this.correctSmallAudios,
    required this.sampleWords,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    final script = (json['scriptTags'] as List).first;

    return Topic(
      topicName: json['topicName'],
      correctCapitalAudios: List<String>.from(script['correctCapitalAudios']),
      correctSmallAudios: List<String>.from(script['correctSmallAudios']),
      sampleWords: List<String>.from(script['sampleWords']),
    );
  }
}
