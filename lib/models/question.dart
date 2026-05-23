class Question {
  final int id;
  final String question;
  final List<Option> options;
  final String answer;
  final String type;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] as num).toInt(),
      question: '${json['question'] ?? ''}',
      options: json['options'] == null
          ? <Option>[]
          : (json['options'] as List)
              .map((o) => Option.fromJson(o as Map<String, dynamic>))
              .toList(),
      answer: '${json['answer'] ?? ''}',
      type: '${json['type'] ?? 'single'}',
    );
  }

  bool get isSingle => type == 'single';
  bool get isMulti => type == 'multi';
  bool get isJudge => type == 'judge';
}

class Option {
  final String label;
  final String text;

  Option({required this.label, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      label: '${json['label'] ?? ''}',
      text: '${json['text'] ?? ''}',
    );
  }
}

class TikuData {
  final String title;
  final int total;
  final List<Question> questions;

  TikuData({
    required this.title,
    required this.total,
    required this.questions,
  });

  factory TikuData.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested meta formats
    String title;
    int total;
    List<dynamic> rawQuestions;

    if (json['meta'] != null) {
      final meta = json['meta'] as Map<String, dynamic>;
      title = '${meta['title'] ?? '保安员考试题库'}';
      total = (meta['total'] as num?)?.toInt() ?? 0;
      rawQuestions = (json['questions'] as List<dynamic>?) ?? [];
    } else {
      title = '${json['title'] ?? '保安员考试题库'}';
      total = (json['total'] as num?)?.toInt() ?? 0;
      rawQuestions = (json['questions'] as List<dynamic>?) ?? [];
    }

    return TikuData(
      title: title,
      total: total,
      questions: rawQuestions
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
