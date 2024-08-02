import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  final double _height;
  final double _width;

  Responsive(this.context)
      : _height = MediaQuery.of(context).size.height,
        _width = MediaQuery.of(context).size.width;

  double heightPercentage(double percentage) {
    return _height * percentage / 100;
  }

  double widthPercentage(double percentage) {
    return _width * percentage / 100;
  }

  double textSize(double percentage) {
    return (_width + _height) * percentage / 200;
  }

  EdgeInsetsGeometry paddingPercentage(double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      widthPercentage(left),
      heightPercentage(top),
      widthPercentage(right),
      heightPercentage(bottom),
    );
  }

  EdgeInsetsGeometry marginPercentage(double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      widthPercentage(left),
      heightPercentage(top),
      widthPercentage(right),
      heightPercentage(bottom),
    );
  }

  EdgeInsetsGeometry symmetricPaddingPercentage(double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: widthPercentage(horizontal),
      vertical: heightPercentage(vertical),
    );
  }

  EdgeInsetsGeometry symmetricMarginPercentage(double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: widthPercentage(horizontal),
      vertical: heightPercentage(vertical),
    );
  }

  BorderRadiusGeometry borderRadiusPercentage(double radius) {
    return BorderRadius.circular(widthPercentage(radius));
  }
}
