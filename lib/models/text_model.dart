class TextModel {
  String text;
  bool? isCorrect;

  TextModel({required this.text, this.isCorrect});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextModel &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isCorrect == other.isCorrect;

  @override
  int get hashCode => text.hashCode ^ isCorrect.hashCode;
}
