import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A reusable error placeholder widget for failed image loads
class ErrorImage extends StatelessWidget {
  final String errorMessage;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const ErrorImage({
    super.key,
    required this.errorMessage,
    this.width = 200,
    this.height = 200,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: backgroundColor ?? AppTheme.errorBackground,
        width: width,
        height: height,
        child: Center(
          child: Text(
            errorMessage,
            style: TextStyle(
              color: textColor ?? AppTheme.errorTextColor,
              fontSize: fontSize ?? 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// A square error image with default dimensions
class SquareErrorImage extends StatelessWidget {
  final String errorMessage;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const SquareErrorImage({
    super.key,
    required this.errorMessage,
    this.size = 200,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorImage(
      errorMessage: errorMessage,
      width: size,
      height: size,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}

/// A circular error image
class CircularErrorImage extends StatelessWidget {
  final String errorMessage;
  final double diameter;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const CircularErrorImage({
    super.key,
    required this.errorMessage,
    this.diameter = 200,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.errorBackground,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          errorMessage,
          style: TextStyle(
            color: textColor ?? AppTheme.errorTextColor,
            fontSize: fontSize ?? 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}