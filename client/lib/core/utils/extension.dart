import 'package:flutter/material.dart';

extension SizedBoxExtension on int {
  SizedBox get verticalSpacer => SizedBox(height: toDouble());
  SizedBox get horizontalSpacer => SizedBox(width: toDouble());
}

extension BuildContextExtension on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get height => screenSize.height;
  double get width => screenSize.width;

  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void pop() {
    Navigator.of(this).pop();
  }
}

extension SnackBarExtension on BuildContext {
  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}
