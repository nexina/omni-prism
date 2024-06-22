import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:omni_prism/imageviewer_frame.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter/material.dart';
import 'package:omni_prism/classItems.dart';
import 'package:omni_prism/funtions.dart';

import 'package:omni_prism/imageviewer_component.dart';

String imagePath = "";
String folderPath = "";
String projectUrl = "https://github.com/nexina/omni-prism";
String facebookUrl = "https://www.facebook.com/nexina.corp/";
String omniUrl = "https://nexina.github.io/omni";

// This is the main function
// This will run the essentials and start the app
void main(List<String> args) async {
  if (args.isNotEmpty) {
    imagePath = args[0];
    folderPath = getImagePath(imagePath);
  }

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions);
  }
  runApp(const Start());
}

// List of all the images in the folder and get the length of the list
List<ImageItem> imageList = [];
int imageListLength = imageList.length;

// List of all the supported image extensions
List<String> extensions = [
  '.jpg',
  '.png',
  '.jpeg',
  '.gif',
  '.webp',
  '.bmp',
  '.tiff',
  '.svg',
  '.eps',
  '.raw',
  '.cr2',
  '.nef',
  '.orf',
  '.sr2',
  '.pef',
  '.dng',
  '.x3f',
  '.arw',
  '.rw2',
  '.rwl',
  '.tif',
  '.heic',
  '.indd',
  '.ai',
  '.psd',
  '.svgz',
  '.eps',
  '.pdf',
  '.pct',
  '.wmf',
  '.emf',
  '.ico',
  '.icon',
  '.webp'
];

// This is the main class of the app
class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;
  final GlobalKey<ImageComponentState> _imageComponentKey =
      GlobalKey<ImageComponentState>();

  int imageIndex = -1;
  String imageTitle = "Untitled";
  String imageCreationTime = "2000-01-01 12:00:00.000";
  String currentImagePath = "";
  String projectName = "Project Omni";

  bool isVisible = true;
  bool isFullscreen = false;

  Icon fullscreenIcon = const Icon(
    Icons.zoom_out_map_sharp,
    color: Colors.white,
  );
  Icon visibilityIcon = const Icon(
    Icons.visibility,
    color: Colors.white,
  );

  //// class Start functions

  // Set the image details
  void setImageDetail(ImageItem imageItem) {
    setState(() {
      imageTitle = imageItem.title;
      imageCreationTime = imageItem.CreationTime;
      currentImagePath = imageItem.path;
    });
  }

  // Add all the images in the folder to the imageList and return the opened images index
  Future<int> addImages(String folderPath) async {
    int index = -1;

    await getImageFiles(folderPath).then((value) {
      for (var file in value) {
        setState(() {
          if (extensions.any((extension) => file.path.endsWith(extension))) {
            if (file.path == imagePath && imageIndex == -1) {
              index = imageListLength;
            }

            ImageItem it = ImageItem();
            it.path = file.path;
            it.title = file.path.split('\\').last;
            DateTime modified = file.statSync().modified;
            it.CreationTime =
                DateFormat('dd MMM yyyy, hh:mm a').format(modified);
            imageList.add(it);
          }
        });
      }
    });

    return index;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      imageIndex = await addImages(
          folderPath); // return opened images position after getting all the images in ImageList
    });

    _timer = Timer(Duration.zero, () {});
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1.0).animate(_controller);
    _controller.forward();
  }

// set Fullscreen mode
  void setFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
      if (isFullscreen) {
        fullscreenIcon = const Icon(
          Icons.zoom_in_map_sharp,
          color: Colors.white,
        );
      } else {
        fullscreenIcon = const Icon(
          Icons.zoom_out_map_sharp,
          color: Colors.white,
        );
      }
      windowManager.setFullScreen(isFullscreen);
    });
  }

// set Visibility for frame
  void setVisibility() {
    setState(() {
      isVisible = !isVisible;
      if (isVisible) {
        _controller.forward();
        visibilityIcon = const Icon(
          Icons.visibility,
          color: Colors.white,
        );
      } else {
        _controller.reverse();
        visibilityIcon = const Icon(
          Icons.visibility_off,
          color: Colors.white,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: const Color.fromARGB(125, 0, 0, 0),
          body: Center(
              child: (imageList.isNotEmpty)
                  ? Stack(children: [
                      Stack(children: [
                        GestureDetector(
                          onTap: () {
                            if (!isVisible) setVisibility();
                          },
                          child: ImageComponent(
                            key: _imageComponentKey,
                            imageList: imageList,
                            imageIndex: imageIndex,
                            setImageDetail: setImageDetail,
                            setFullscreen: setFullscreen,
                          ),
                        ),
                        NPButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            alignment: Alignment.centerLeft,
                            animation: _animation,
                            controller: _controller,
                            doNF: () {
                              _imageComponentKey.currentState?.prevImage();
                            }),
                        NPButton(
                          icon: const Icon(Icons.arrow_forward,
                              color: Colors.white),
                          doNF: () {
                            _imageComponentKey.currentState?.nextImage();
                          },
                          alignment: Alignment.centerRight,
                          animation: _animation,
                          controller: _controller,
                        ),
                      ]),
                      TopBar(
                          controller: _controller,
                          animation: _animation,
                          alignment: Alignment.topCenter,
                          imageTitle: imageTitle,
                          imageCreationTime: imageCreationTime,
                          currentImagePath: currentImagePath,
                          visibilityIcon: visibilityIcon,
                          fullscreenIcon: fullscreenIcon,
                          setVisibility: setVisibility,
                          setFullscreen: setFullscreen,
                          removeCurrentImageFromList: () {
                            _imageComponentKey.currentState
                                ?.removeCurrentImage();
                          }),
                      BottomBar(
                        alignment: Alignment.bottomCenter,
                        controller: _controller,
                        animation: _animation,
                        projectName: projectName,
                        imageIndex: imageIndex,
                        imageList: imageList,
                        setImageDetail: setImageDetail,
                      )
                    ])
                  : Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 65, 65, 65),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: extensions
                                  .map((extension) => extension.substring(1))
                                  .toList(),
                            );
                            if (result != null) {
                              imagePath = result.files.single.path!;
                              folderPath = getImagePath(imagePath);
                              imageList.clear();
                              addImages(folderPath).then((value) {
                                setState(() {
                                  imageIndex = value;
                                });
                              });
                            }
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(18.0),
                                child: Image(
                                  image: AssetImage("images/omni_prism_ic.png"),
                                  height: 50,
                                ),
                              ),
                              Text("Open Image",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ))),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}
