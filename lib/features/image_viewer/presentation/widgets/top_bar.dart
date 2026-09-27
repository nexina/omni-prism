import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Top bar widget for the image viewer
class TopBar extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final String imageTitle;
  final String imageCreationTime;
  final String currentImagePath;
  final bool isVisible;
  final bool isFullscreen;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onFullscreenToggle;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onAbout;

  const TopBar({
    super.key,
    required this.controller,
    required this.animation,
    required this.imageTitle,
    required this.imageCreationTime,
    required this.currentImagePath,
    required this.isVisible,
    required this.isFullscreen,
    required this.onVisibilityToggle,
    required this.onFullscreenToggle,
    required this.onDelete,
    required this.onShare,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: AppConstants.topBarHeight,
              color: AppTheme.topBarBackground,
              child: Row(
                children: [
                  // App icon / back button
                  _buildLeading(context),
                  // Image title and creation time
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            imageTitle,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.titleStyle,
                          ),
                          Text(
                            imageCreationTime,
                            style: AppTheme.subtitleStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Action buttons
                  _buildActionButton(
                    icon: Icons.share,
                    onPressed: onShare,
                  ),
                  _buildActionButton(
                    icon: isVisible ? Icons.visibility : Icons.visibility_off,
                    onPressed: onVisibilityToggle,
                  ),
                  _buildActionButton(
                    icon: isFullscreen ? Icons.zoom_in_map_sharp : Icons.zoom_out_map_sharp,
                    onPressed: onFullscreenToggle,
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    onPressed: onDelete,
                  ),
                  _buildMenuButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading(BuildContext context) {
    return SizedBox(
      width: AppConstants.topBarHeight,
      height: AppConstants.topBarHeight,
      child: Center(
        child: IconButton(
          onPressed: () {
            // Try to launch the omni URL
            canLaunchUrlString(AppConstants.omniUrl).then((canLaunch) {
              if (canLaunch) launchUrlString(AppConstants.omniUrl);
            });
          },
          icon: Image.asset(
            AppConstants.appIconPath,
            isAntiAlias: true,
            fit: BoxFit.contain,
            width: AppConstants.largeIconSize,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image, color: Colors.white, size: 24);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: AppConstants.navButtonWidth,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuButton() {
    return SizedBox(
      width: AppConstants.navButtonWidth,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onSelected: (String result) {
          switch (result) {
            case 'Set As Wallpaper':
              // TODO: Implement set wallpaper
              break;
            case 'Show Information':
              // TODO: Show image info dialog
              break;
            case 'About':
              onAbout();
              break;
            case 'Exit':
              SystemNavigator.pop();
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'Set As Wallpaper',
            child: Text('Set As Wallpaper'),
          ),
          const PopupMenuItem<String>(
            value: 'Show Information',
            child: Text('Show Information'),
          ),
          const PopupMenuItem<String>(
            value: 'About',
            child: Text('About'),
          ),
          const PopupMenuItem<String>(
            value: 'Exit',
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
}