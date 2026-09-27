import 'package:flutter/material.dart';

/// A reusable animated icon button with fade-in/out animation
class AnimatedIconButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final VoidCallback onPressed;
  final Icon icon;
  final Alignment alignment;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedIconButton({
    super.key,
    required this.controller,
    required this.animation,
    required this.onPressed,
    required this.icon,
    required this.alignment,
    this.width,
    this.height,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: SizedBox(
              width: width,
              height: height,
              child: Material(
                color: backgroundColor ?? Colors.transparent,
                borderRadius: borderRadius,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: borderRadius,
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: icon.color,
                        size: icon.size,
                      ),
                      child: icon,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A simpler animated button that just fades in/out
class FadeAnimatedButton extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;
  final Widget child;
  final Alignment alignment;
  final double? width;
  final double? height;

  const FadeAnimatedButton({
    super.key,
    required this.animation,
    required this.onPressed,
    required this.child,
    required this.alignment,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: SizedBox(
              width: width,
              height: height,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

/// A navigation button specifically for left/right navigation in image viewers
class NavigationButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final VoidCallback onPressed;
  final IconData icon;
  final Alignment alignment;
  final double width;
  final double height;
  final Color iconColor;
  final Color? backgroundColor;

  const NavigationButton({
    super.key,
    required this.controller,
    required this.animation,
    required this.onPressed,
    required this.icon,
    required this.alignment,
    this.width = 60,
    this.height = 250,
    this.iconColor = Colors.white,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedIconButton(
      controller: controller,
      animation: animation,
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor),
      alignment: alignment,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
    );
  }
}