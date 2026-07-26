import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textStyles => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}
