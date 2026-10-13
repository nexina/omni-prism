import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../router/app_router.dart';

/// "NEXINA / O M N I" brand mark
class CompanyIcon extends StatelessWidget {
  const CompanyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            AppConstants.companyIconPath,
            height: 20,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
        const Text(
          '/',
          style: TextStyle(
            fontSize: 15.0,
            color: Color.fromARGB(255, 180, 180, 180),
            fontFamily: AppConstants.fontFamily,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'O M N I',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}

/// Footer with the brand mark; tapping it opens the About page
class OmniFooter extends StatelessWidget {
  const OmniFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: AppRouter.navigateToAbout,
            child: const CompanyIcon(),
          ),
        ),
      ),
    );
  }
}
