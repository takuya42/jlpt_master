enum AppRoute {
  home('/', 'Home（ホーム）'),
  login('/login', 'Login（ログイン）'),
  emailLogin('/login/email', 'Email Login（メールログイン）'),
  register('/register', 'Register（新規登録）'),
  vocabulary('/vocabulary', 'Vocabulary（単語）'),
  vocabularyDetail('/vocabulary/:wordId', 'Vocabulary Detail（単語詳細）'),
  grammar('/grammar', 'Grammar（文法）'),
  statistics('/statistics', 'Statistics（学習記録）'),
  settings('/settings', 'Settings（設定）'),
  premium('/premium', 'Premium');

  const AppRoute(this.path, this.label);

  final String path;
  final String label;

  static String vocabularyDetailPath(String wordId) => '/vocabulary/$wordId';
}
