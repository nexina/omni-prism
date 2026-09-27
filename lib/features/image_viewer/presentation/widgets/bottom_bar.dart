import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/theme.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:omni_prism/features/image_viewer/presentation/widgets/image_overview.dart';

/// Bottom bar widget for the image viewer
class BottomBar extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final String projectName;
  final List<String> imagePaths;
  final int currentIndex;
  final ScrollController scrollController;
  final void Function(int index) onImageTap;

  const BottomBar({
    super.key,
    required this.controller,
    required this.animation,
    required this.projectName,
    required this.imagePaths,
    required this.currentIndex,
    required this.scrollController,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final dragIndicator = const Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Icon(
          Icons.circle_rounded,
          color: Color(0x64FFFFFF),
          size: 5,
        ),
      ),
    );

    final thumbnailStrip = SizedBox(
      height: 70,
      child: ImageOverview(
        imagePaths: imagePaths,
        currentIndex: currentIndex,
        scrollController: scrollController,
        onImageTap: onImageTap,
      ),
    );

    final projectLink = GestureDetector(
      onTap: () async {
        if (await canLaunchUrlString(AppConstants.projectUrl)) {
          await launchUrlString(AppConstants.projectUrl);
        }
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingSmall),
          child: Text(
            projectName.toUpperCase(),
            style: AppTheme.projectNameStyle,
          ),
        ),
      ),
    );

    final columnContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dragIndicator,
        thumbnailStrip,
        projectLink,
      ],
    );

    final animatedContent = AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: columnContent,
        );
      },
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: animatedContent,
    );
  }
}