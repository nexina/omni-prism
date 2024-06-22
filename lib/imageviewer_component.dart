import "dart:io";
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:omni_prism/classItems.dart';
import 'package:omni_prism/main.dart';

int imageCache = 10;
int currentImageIndex = 0;

//// Image Component ////
/// This widget is used to display the pages of image in the image viewer
class ImageComponent extends StatefulWidget {
  final int imageIndex;
  final List<ImageItem> imageList;
  final Function(ImageItem) setImageDetail;
  final Function setFullscreen;
  const ImageComponent(
      {super.key,
      required this.imageIndex,
      required this.imageList,
      required this.setImageDetail,
      required this.setFullscreen});

  @override
  State<ImageComponent> createState() => ImageComponentState();
}

List<ImageItem> icList = [];
int icListIndex = 0;

ScrollController _scrollOverviewController = ScrollController();
PageController _pageComponentController = PageController();
bool lastImage =
    false; // Check if the icList contains the last image of imageList
bool firstImage =
    false; // Check if the icList contains the first image of imageList

int begin =
    0; // The beginning index of the imageList as per with icList first index
int end = 0; // The ending index of the imageList as per with icList last index

bool isTransitioning =
    false; // Check if the image is transitioning, to make sure no other transition happens

// Change the scroll position of the image overview and the image component
Future<void> animateToPosition(int index) async {
  // transition is now happening
  isTransitioning = true;
  // Check if the page controller and the scroll controller has clients and scroll page as per to icList
  if (_pageComponentController.hasClients) {
    _pageComponentController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  // Check if the scroll controller has clients and scroll overview as per to imageList
  if (_scrollOverviewController.hasClients) {
    _scrollOverviewController.animateTo((currentImageIndex * 60),
        duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);
  }
  // transition is now done
  isTransitioning = false;
}

// Generate the new list of images
Future<List<ImageItem>> newImageList(int index) async {
  List<ImageItem> newList = [];
  begin = (index ~/ imageCache) * imageCache;
  (begin == 0) ? firstImage = true : firstImage = false;

  end = (begin + imageCache - 1) > imageList.length
      ? imageList.length - 1
      : begin + imageCache - 1;
  (end == imageList.length - 1) ? lastImage = true : lastImage = false;

  for (int i = begin; i <= end; i++) {
    newList.add(imageList[i]);
  }

  return newList;
}

// returnform = 0 -> initialized/assigned
// returnform = 1 -> next
// returnform = 2 -> previous
// get partitioned list of images to icList and adjust the icListIndex
Future<void> partitionList(int index, int returnfrom) async {
  icList.clear();

  // Generate the new list of images from imageList to icList
  return newImageList(index).then((value) {
    icList = value;

    if (returnfrom == 2) {
      icListIndex = imageCache - 1;
    } else if (returnfrom == 1) {
      icListIndex = 0;
    } else {
      currentImageIndex = index;
      icListIndex = index % imageCache;
    }
  });
}

class ImageComponentState extends State<ImageComponent> {
  @override
  void initState() {
    super.initState();

    currentImageIndex = widget.imageIndex;

    partitionList(currentImageIndex, 0).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          onIndexUpdate(icListIndex);
        });
      });
    });
  }

  void removeCurrentImage() {
    setState(() {
      imageList.removeAt(currentImageIndex);
      icList.removeAt(icListIndex);

      if (currentImageIndex == imageList.length - 1) {
        icListIndex--;
        currentImageIndex--;
      }

      onIndexUpdate(icListIndex);
    });
  }

  // Do the necessary changes when the index is updated
  void onIndexUpdate(int index) {
    animateToPosition(index);
    widget.setImageDetail(icList[index]);
  }

  // Go to the next image
  void nextImage() {
    if (isTransitioning) return;
    if (!lastImage || icListIndex < icList.length - 1) {
      icListIndex++;
      currentImageIndex++;
    }

    // if icListIndex is greater than or equal to imageCache, then partition the next imageCache amount list
    if (icListIndex >= imageCache && lastImage == false) {
      partitionList(end + 1, 1).then((_) {
        onIndexUpdate(icListIndex);
      });
    } else {
      onIndexUpdate(icListIndex);
    }
  }

  // Go to the previous image
  void prevImage() {
    if (isTransitioning) return;
    if (!firstImage || icListIndex > 0) {
      icListIndex--;
      currentImageIndex--;
    }

    // if icListIndex is greater than or equal to imageCache, then partition the next imageCache amount list
    if (icListIndex < 0 && firstImage == false) {
      partitionList(begin - 1, 2).then((_) {
        onIndexUpdate(icListIndex);
      });
    } else {
      onIndexUpdate(icListIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: _pageComponentController,
      // onPageChanged: (index) {
      //   setState(() {
      //     if (goToClicked) {
      //       goToClicked = false;
      //       return;
      //     }
      //     if (index > icListIndex) {
      //       currentImageIndex += (index - icListIndex);
      //     } else if (index < icListIndex) {
      //       currentImageIndex -= (icListIndex - index);
      //     }
      //     icListIndex = index;

      //     if (_scrollOverviewController.hasClients) {
      //       _scrollOverviewController.animateTo((currentImageIndex * 60),
      //           duration: const Duration(milliseconds: 150),
      //           curve: Curves.easeInOut);
      //     }
      //   });
      // },
      itemBuilder: (context, index) {
        return ImageComponentItem(
          imagePath: icList[index].path,
          setFullscreen: widget.setFullscreen,
          nextImage: nextImage,
          prevImage: prevImage,
        );
      },
      itemCount: icList.length,
    );
  }
}

//// Image Overview ////
/// This widget is used to display the list of images at the bottom of the image viewer
class ImageOverview extends StatefulWidget {
  final int index;
  final List<ImageItem> imageList;
  final Function(ImageItem) setImageDetail;
  const ImageOverview(
      {super.key,
      required this.index,
      required this.imageList,
      required this.setImageDetail});

  @override
  State<ImageOverview> createState() => _ImageOverviewState();
}

class _ImageOverviewState extends State<ImageOverview> {
  // Go to the image at the given index
  void gotoImage(int index) async {
    setState(() {
      partitionList(index, 0).then((_) {
        currentImageIndex = index;
        icListIndex = index % imageCache;
        animateToPosition(icListIndex);
        widget.setImageDetail(icList[icListIndex]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ListView.builder(
          controller: _scrollOverviewController,
          // shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: (index == 0)
                  ? EdgeInsets.only(
                      left: (MediaQuery.of(context).size.width / 2) - 20)
                  : (index == imageList.length - 1)
                      ? EdgeInsets.only(
                          right: (MediaQuery.of(context).size.width / 2) - 20)
                      : const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      gotoImage(index);
                    });
                  },
                  child: ImageOverviewItem(
                      imageListItemPath: widget.imageList[index].path)),
            );
          },
          itemCount: widget.imageList.length);
    });
  }
}

//// Image Component Item ////
/// This widget is used to display the image in the image viewer
class ImageComponentItem extends StatefulWidget {
  final String imagePath;
  final Function setFullscreen;
  final Function nextImage;
  final Function prevImage;
  const ImageComponentItem(
      {super.key,
      required this.imagePath,
      required this.setFullscreen,
      required this.nextImage,
      required this.prevImage});

  @override
  State<ImageComponentItem> createState() => _ImageComponentItemState();
}

class _ImageComponentItemState extends State<ImageComponentItem> {
  bool _isImage = false; // Check if the mouse is on the image
  bool _isZoomed = false; // Check if the image is zoomed
  final TransformationController _tcontroller = TransformationController();
  double minScaleFactor = 0.1;
  double minScale = 0.1;
  double maxScale = 4.0;

  void scaleImage(double scaleFactor, Offset localPosition) {
    double currentScale = _tcontroller.value.getMaxScaleOnAxis();

    // Compute the new scale by multiplying the current scale with the incoming scale factor
    double newScale = currentScale * scaleFactor;

    // Clamp the new scale to ensure it remains above the minimum scale factor
    newScale = newScale < minScaleFactor ? minScaleFactor : newScale;

    // Compute the scale adjustment factor
    double scaleAdjustmentFactor = newScale / currentScale;

    // Create the zoom transformation matrix
    Matrix4 zoomMatrix = Matrix4.identity()
      ..translate(
          localPosition.dx, localPosition.dy) // Translate to the tapped point
      ..scale(scaleAdjustmentFactor) // Apply the normalized scale adjustment
      ..translate(-localPosition.dx, -localPosition.dy); // Translate back

    Matrix4 newValue = _tcontroller.value.multiplied(zoomMatrix);

    // Check for zero matrix and prevent assignment if invalid
    if (newValue.determinant() != 0.0) {
      _tcontroller.value = newValue;
      _isZoomed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: GestureDetector(
          onDoubleTapDown: (TapDownDetails details) {
            setState(() {
              if (_isImage) {
                // Check if the mouse is on the image
                if (_isZoomed) {
                  // Check if the image is zoomed, then reset the zoom
                  _tcontroller.value = Matrix4.identity();
                  _isZoomed = false;
                } else {
                  // Zoom the image 3x time
                  scaleImage(3, details.localPosition);
                }
              } else {
                // If the mouse is not on the image, set the fullscreen mode
                widget.setFullscreen();
              }
            });
          },
          child: InteractiveViewer(
            boundaryMargin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 2,
                vertical: MediaQuery.of(context).size.height / 2),
            minScale: minScale,
            maxScale: maxScale,
            scaleFactor: 0.01,
            transformationController: _tcontroller,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 90.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: MouseRegion(
                  onEnter: (_) {
                    _isImage = true;
                  },
                  onExit: (_) {
                    _isImage = false;
                  },
                  cursor: SystemMouseCursors.move,
                  child: Image.file(
                    File(widget.imagePath),
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return const ErrorImage(
                          errorMessage: 'Error loading image');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//// Image Overview Item ////
/// This widget is used to display the image at the bottom of the list viewer
class ImageOverviewItem extends StatefulWidget {
  final String imageListItemPath;
  const ImageOverviewItem({super.key, required this.imageListItemPath});

  @override
  State<ImageOverviewItem> createState() => _ImageOverviewItemState();
}

class _ImageOverviewItemState extends State<ImageOverviewItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double initOpacity = 0.6;
  double finalOpacity = 1.0;
  int duration = 200;
  double imageOverviewItemWidth = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );
    _animation = Tween<double>(begin: initOpacity, end: finalOpacity)
        .animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) => _controller.forward(),
      onExit: (PointerExitEvent event) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Image.file(
              File(widget.imageListItemPath),
              width: imageOverviewItemWidth,
              cacheWidth: imageOverviewItemWidth.toInt(),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return ErrorImage(
                  errorMessage: 'NaN',
                  width: imageOverviewItemWidth,
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//// Error Image ////
class ErrorImage extends StatelessWidget {
  final String errorMessage;
  final double width;
  const ErrorImage({super.key, required this.errorMessage, this.width = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black,
        width: width,
        height: width,
        child: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 0, 0),
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
