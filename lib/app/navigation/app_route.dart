enum AppRoute {
  home('/', 'Home'),
  vocabulary('/vocabulary', 'Vocabulary'),
  grammar('/grammar', 'Grammar'),
  kanji('/kanji', 'Kanji'),
  mockExam('/mock-exam', 'Mock Exam'),
  settings('/settings', 'Settings');

  const AppRoute(this.path, this.label);

  final String path;
  final String label;
}
