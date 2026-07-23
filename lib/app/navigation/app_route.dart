enum AppRoute {
  home('/', 'Home（ホーム）'),
  login('/login', 'Login（ログイン）'),
  emailLogin('/login/email', 'Email Login（メールログイン）'),
  register('/register', 'Register（新規登録）'),
  vocabulary('/vocabulary', 'Vocabulary（単語）'),
  vocabularyDetail('/vocabulary/:wordId', 'Vocabulary Detail（単語詳細）'),
  grammar('/grammar', 'Grammar（文法）'),
  grammarDetail('/grammar/:grammarId', 'Grammar Detail（文法詳細）'),
  notes('/notes', 'Notes（メモ）'),
  settings('/settings', 'Settings（設定）'),
  proPlan('/settings/pro', 'Pro Plan'),
  favorite('/favorite', 'Favorite（お気に入り）'),
  learningGoal('/learning-goal', 'Learning Goal（学習目標）');

  const AppRoute(this.path, this.label);

  final String path;
  final String label;

  static String vocabularyDetailPath(String wordId) => '/vocabulary/$wordId';
  static String grammarDetailPath(String grammarId) => '/grammar/$grammarId';
}
