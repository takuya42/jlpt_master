enum AppRoute {
  home('/', 'Home（ホーム）'),
  login('/login', 'Login（ログイン）'),
  vocabulary('/vocabulary', 'Vocabulary（単語）'),
  vocabularyDetail('/vocabulary/:wordId', 'Vocabulary Detail（単語詳細）'),
  grammar('/grammar', 'Grammar（文法）'),
  statistics('/statistics', 'Statistics（学習記録）'),
  settings('/settings', 'Settings（設定）');

  const AppRoute(this.path, this.label);

  final String path;
  final String label;

  static String vocabularyDetailPath(String wordId) => '/vocabulary/$wordId';
}
