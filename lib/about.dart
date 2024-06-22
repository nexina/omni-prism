import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:omni_prism/main.dart';
import 'package:url_launcher/url_launcher_string.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Container(
        color: const Color.fromARGB(255, 25, 25, 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('images/omni_prism_ic.png'),
                  width: 200,
                  fit: BoxFit.fitHeight,
                ),
                Text(
                  'Omni Prism',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  '0.0.1',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 400,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color.fromARGB(
                          255, 255, 255, 255)), // Default text style
                  children: <TextSpan>[
                    const TextSpan(
                        text:
                            "Omni Prism © 2024 by Rakibul Hasan is licensed under Creative Commons Attribution-NonCommercial 4.0 International. To view a copy of this license, visit "),
                    TextSpan(
                      text: "https://creativecommons.org/licenses/by-nc/4.0/",
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url =
                              'https://creativecommons.org/licenses/by-nc/4.0/';
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(url);
                          } else {
                            await launchUrlString(projectUrl);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                  onPressed: () async {
                    if (await canLaunchUrlString(projectUrl)) {
                      await launchUrlString(projectUrl);
                    }
                  },
                  icon: const Icon(
                    Icons.public,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () async {
                    if (await canLaunchUrlString(facebookUrl)) {
                      await launchUrlString(facebookUrl);
                    }
                  },
                  icon: const Icon(
                    Icons.facebook,
                    color: Colors.white,
                  )),
            ])
          ],
        ),
      ),
    );
  }
}
