import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/theme.dart';
import 'package:omni_prism/features/about/presentation/bloc/about_bloc.dart';

/// About page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AboutBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About'),
          backgroundColor: AppTheme.topBarBackground,
        ),
        body: Container(
          color: AppTheme.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppConstants.appIconPath,
                    width: AppConstants.aboutIconSize,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 100, color: Colors.white);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Omni Prism',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.1',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 400,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                        text:
                            'Omni Prism is an open-source image viewer application. '
                            'For licensing information, visit ',
                      ),
                      TextSpan(
                        text: 'https://creativecommons.org/licenses/by-nc/4.0/',
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            if (await canLaunchUrlString(
                                'https://creativecommons.org/licenses/by-nc/4.0/')) {
                              await launchUrlString(
                                  'https://creativecommons.org/licenses/by-nc/4.0/');
                            } else {
                              await launchUrlString(AppConstants.projectUrl);
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (await canLaunchUrlString(AppConstants.projectUrl)) {
                        await launchUrlString(AppConstants.projectUrl);
                      }
                    },
                    icon: const Icon(
                      Icons.public,
                      color: Colors.white,
                    ),
                    tooltip: 'Project Website',
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await canLaunchUrlString(AppConstants.facebookUrl)) {
                        await launchUrlString(AppConstants.facebookUrl);
                      }
                    },
                    icon: const Icon(
                      Icons.facebook,
                      color: Colors.white,
                    ),
                    tooltip: 'Facebook',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}