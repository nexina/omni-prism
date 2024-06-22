import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omni_prism/classItems.dart';
import 'package:omni_prism/about.dart';
import 'package:omni_prism/imageviewer_component.dart';
import 'package:omni_prism/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NPButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final Function doNF;
  final Icon icon;
  final Alignment alignment;
  const NPButton(
      {super.key,
      required this.controller,
      required this.animation,
      required this.icon,
      required this.alignment,
      required this.doNF});

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
                height: 250,
                width: 60,
                child: IconButton(
                    icon: icon,
                    onPressed: () {
                      doNF();
                    }),
              ),
            );
          }),
    );
  }
}

class TopBar extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final Icon visibilityIcon;
  final Icon fullscreenIcon;
  final Alignment alignment;
  final String imageTitle;
  final String imageCreationTime;
  final String currentImagePath;
  final Function setVisibility;
  final Function setFullscreen;
  final Function removeCurrentImageFromList;
  const TopBar(
      {super.key,
      required this.controller,
      required this.animation,
      required this.alignment,
      required this.imageTitle,
      required this.imageCreationTime,
      required this.currentImagePath,
      required this.visibilityIcon,
      required this.fullscreenIcon,
      required this.setVisibility,
      required this.setFullscreen,
      required this.removeCurrentImageFromList});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color.fromARGB(200, 12, 12, 12);
    double mainHeight = 50.0;
    String appIcon = 'images/omni_prism_ic.png';
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: mainHeight,
                color: backgroundColor,
                child: Row(
                  children: [
                    (Platform.isAndroid || Platform.isIOS)
                        ? SizedBox(
                            width: mainHeight,
                            height: mainHeight,
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                )),
                          )
                        : Container(
                            color: const Color.fromARGB(255, 51, 51, 51),
                            width: mainHeight,
                            height: mainHeight,
                            child: Center(
                              child: IconButton(
                                onPressed: () async {
                                  if (await canLaunchUrlString(omniUrl)) {
                                    await launchUrlString(omniUrl);
                                  }
                                },
                                icon: Image.asset(
                                  appIcon,
                                  isAntiAlias: true,
                                  fit: BoxFit.contain,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(imageTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              Text(imageCreationTime,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: IconButton(
                          onPressed: () async {
                            final XFile image = XFile(currentImagePath);
                            await Share.shareXFiles([image],
                                text: 'Share image via -');
                          },
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          )),
                    ),
                    SizedBox(
                      width: 60,
                      child: IconButton(
                          onPressed: () {
                            setVisibility();
                          },
                          icon: visibilityIcon),
                    ),
                    SizedBox(
                      width: 60,
                      child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: ((context) => AlertDialog(
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              final File file =
                                                  File(currentImagePath);
                                              try {
                                                await file.delete();
                                                removeCurrentImageFromList();
                                              } catch (e) {
                                                // Handle the error here.
                                              }
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Delete")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancel"))
                                      ],
                                      title: Text(
                                        "Delete \"$imageTitle\"",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      content: const Text(
                                          "This image will be deleted permanently. Are you sure?"),
                                    )));
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          )),
                    ),
                    SizedBox(
                      width: 60,
                      child: IconButton(
                          onPressed: () {
                            setFullscreen();
                          },
                          icon: fullscreenIcon),
                    ),
                    SizedBox(
                      width: 60,
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onSelected: (String result) {
                          switch (result) {
                            case 'Set As Wallpaper':
                              break;
                            case 'Show information':
                              break;
                            case 'About':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const About()));
                              break;
                            case 'Exit':
                              exit(0);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Set As Wallpaper',
                            child: Text('Set As Wallpaper'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Show information',
                            child: Text('Show information'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'About',
                            child: Text('About'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Exit',
                            child: Text('Exit'),
                          ),

                          // Add more items for other options
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class BottomBar extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final Alignment alignment;
  final String projectName;
  final List<ImageItem> imageList;
  final int imageIndex;
  final Function(ImageItem) setImageDetail;
  const BottomBar({
    super.key,
    required this.controller,
    required this.animation,
    required this.alignment,
    required this.projectName,
    required this.imageList,
    required this.imageIndex,
    required this.setImageDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.circle_rounded,
                        color: Color.fromARGB(101, 255, 255, 255),
                        size: 5,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ImageOverview(
                      imageList: imageList,
                      index: imageIndex,
                      setImageDetail: setImageDetail,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunchUrlString(projectUrl)) {
                        await launchUrlString(projectUrl);
                      }
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(projectName.toUpperCase(),
                            style: const TextStyle(
                                color: Color.fromARGB(100, 255, 255, 255),
                                fontSize: 7,
                                letterSpacing: 1)),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}
