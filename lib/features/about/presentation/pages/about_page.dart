import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/widgets/background_builder.dart';

/// About page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppConstants.appIconPath,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 30,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.5),
              child: ListView(
                children: [
                  _ListItem(
                    title: 'Visit Website',
                    onPressed: () => _open(AppConstants.omniUrl),
                  ),
                  _ListItem(
                    title: 'Source Code',
                    onPressed: () => _open(AppConstants.projectUrl),
                  ),
                  _ListItem(
                    title: 'Facebook',
                    onPressed: () => _open(AppConstants.facebookUrl),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const _ListItem({required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white70, width: 1)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),
    );
  }
}
