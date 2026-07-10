class GrammarPattern {
  const GrammarPattern(this.expression, this.meaningEn, this.meaningJa, this.example, this.translationEn, this.translationJa, this.level);

  final String expression;
  final String meaningEn;
  final String meaningJa;
  final String example;
  final String translationEn;
  final String translationJa;
  final String level;
}

const grammarPatterns = [
  GrammarPattern('〜てください', 'Please do...', '〜してください', '名前を書いてください。', 'Please write your name.', '名前を書いてください。', 'N5'),
  GrammarPattern('〜なければならない', 'Must do...', '〜しなければならない', '薬を飲まなければなりません。', 'I must take medicine.', '薬を飲まなければなりません。', 'N4'),
  GrammarPattern('〜ことにする', 'Decide to do...', '〜することに決める', '毎朝走ることにしました。', 'I decided to run every morning.', '毎朝走ることにしました。', 'N3'),
  GrammarPattern('〜わけではない', 'It does not mean that...', '〜というわけではない', '嫌いなわけではありません。', 'It does not mean I dislike it.', '嫌いなわけではありません。', 'N2'),
];
