enum AppRoute {
  home('/', 'Home'),
  login('/login', 'Login'),
  vocabulary('/vocabulary', 'Vocabulary'),
  vocabularyDetail('/vocabulary/:wordId', 'Vocabulary Detail'),
  grammar('/grammar', 'Grammar'),
  mockExam('/mock-exam', 'Mock Exam'),
  statistics('/statistics', 'Stats'),
  settings('/settings', 'Settings');

  const AppRoute(this.path, this.label);

  final String path;
  final String label;

  static String vocabularyDetailPath(String wordId) => '/vocabulary/$wordId';
}
