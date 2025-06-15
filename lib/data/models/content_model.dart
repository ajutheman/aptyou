class ContentModel {
  final String lessonId;
  final String lessonName;
  final String lessonDescription;
  final String backgroundAssetUrl;
  final List<TopicModel> topics;

  ContentModel({
    required this.lessonId,
    required this.lessonName,
    required this.lessonDescription,
    required this.backgroundAssetUrl,
    required this.topics,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      lessonId: json['lessonId'],
      lessonName: json['lessonName'],
      lessonDescription: json['lessonDescription'],
      backgroundAssetUrl: json['backgroundAssetUrl'],
      topics: (json['topics'] as List)
          .map((e) => TopicModel.fromJson(e))
          .toList(),
    );
  }
}

class TopicModel {
  final String topicId;
  final String topicName;
  final List<ScriptTagModel> scriptTags;

  TopicModel({
    required this.topicId,
    required this.topicName,
    required this.scriptTags,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      topicId: json['topicId'],
      topicName: json['topicName'],
      scriptTags: (json['scriptTags'] as List)
          .map((e) => ScriptTagModel.fromJson(e))
          .toList(),
    );
  }
}

class ScriptTagModel {
  final String format;
  final String gameType;
  final String gameIntroAudio;
  final List<String> taskAudioCapitalLetter;
  final List<String> taskAudioSmallLetter;
  final List<String> correctCapitalAudios;
  final List<String> correctSmallAudios;
  final String superstarAudio;
  final List<String> tapWrongAudio;
  final List<String> roundPrompts;
  final String finishGameAudio;
  final String cardRewardRive;
  final String finalCelebrationRive;
  final List<String> sampleWords;
  final String buttonText;

  ScriptTagModel({
    required this.format,
    required this.gameType,
    required this.gameIntroAudio,
    required this.taskAudioCapitalLetter,
    required this.taskAudioSmallLetter,
    required this.correctCapitalAudios,
    required this.correctSmallAudios,
    required this.superstarAudio,
    required this.tapWrongAudio,
    required this.roundPrompts,
    required this.finishGameAudio,
    required this.cardRewardRive,
    required this.finalCelebrationRive,
    required this.sampleWords,
    required this.buttonText,
  });

  factory ScriptTagModel.fromJson(Map<String, dynamic> json) {
    return ScriptTagModel(
      format: json['format'],
      gameType: json['gameType'],
      gameIntroAudio: json['gameIntroAudio'],
      taskAudioCapitalLetter: List<String>.from(json['taskAudioCapitalLetter']),
      taskAudioSmallLetter: List<String>.from(json['taskAudioSmallLetter']),
      correctCapitalAudios: List<String>.from(json['correctCapitalAudios']),
      correctSmallAudios: List<String>.from(json['correctSmallAudios']),
      superstarAudio: json['superstarAudio'],
      tapWrongAudio: List<String>.from(json['tapWrongAudio']),
      roundPrompts: List<String>.from(json['roundPrompts']),
      finishGameAudio: json['finishGameAudio'],
      cardRewardRive: json['cardRewardRive'],
      finalCelebrationRive: json['finalCelebrationRive'],
      sampleWords: List<String>.from(json['sampleWords']),
      buttonText: json['buttonText'],
    );
  }
}
