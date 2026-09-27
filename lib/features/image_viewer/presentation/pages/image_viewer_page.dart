import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/core/class/working_file.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/theme.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_bloc.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_event.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_state.dart';
import 'package:omni_prism/features/image_viewer/presentation/widgets/index.dart';
import 'package:omni_prism/features/about/presentation/pages/about_page.dart';

/// Main image viewer page
class ImageViewerPage extends StatefulWidget {
  final WorkingFile workingFile;

  const ImageViewerPage({
    super.key,
    required this.workingFile,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.fadeAnimationDuration),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scrollController = ScrollController();

    _animationController.forward();

    // Load images from the folder
    final folderPath = _getFolderPath(widget.workingFile.workingPath);
    context.read<ImageViewerBloc>().add(
          LoadImages(folderPath: folderPath, initialIndex: 0),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Extracts folder path from a file path
  String _getFolderPath(String filePath) {
    final normalizedPath = filePath.replaceAll('\\', '/');
    final parts = normalizedPath.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImageViewerBloc, ImageViewerState>(
      listener: (context, state) {
        // Handle any side effects
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: BlocBuilder<ImageViewerBloc, ImageViewerState>(
          builder: (context, state) {
            if (state.status == ImageViewerStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.status == ImageViewerStatus.empty) {
              return _buildEmptyState();
            }

            if (state.status == ImageViewerStatus.error) {
              return Center(
                child: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state.status != ImageViewerStatus.loaded ||
                state.currentImage == null) {
              return const SizedBox.shrink();
            }

            return Stack(
              children: [
                // Main image component
                ImageComponent(
                  imageList: state.images,
                  initialIndex: state.currentIndex,
                  onImageChanged: (image) {
                    // Image changed - could update something here
                  },
                  onNextImage: () {
                    context.read<ImageViewerBloc>().add(const NavigateNext());
                  },
                  onPrevImage: () {
                    context.read<ImageViewerBloc>().add(const NavigatePrev());
                  },
                  onDoubleTap: () {
                    context.read<ImageViewerBloc>().add(const ToggleFullscreen());
                  },
                ),
                // Top bar
                TopBar(
                  controller: _animationController,
                  animation: _fadeAnimation,
                  imageTitle: state.currentImage!.title,
                  imageCreationTime: state.currentImage!.creationTime,
                  currentImagePath: state.currentImage!.path,
                  isVisible: state.isVisible,
                  isFullscreen: state.isFullscreen,
                  onVisibilityToggle: () {
                    context.read<ImageViewerBloc>().add(const ToggleVisibility());
                  },
                  onFullscreenToggle: () {
                    context.read<ImageViewerBloc>().add(const ToggleFullscreen());
                  },
                  onDelete: () => _showDeleteDialog(context),
                  onShare: () {
                    context.read<ImageViewerBloc>().add(const ShareCurrent());
                  },
                  onAbout: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),
                // Bottom bar
                BottomBar(
                  controller: _animationController,
                  animation: _fadeAnimation,
                  projectName: 'Project Omni',
                  imagePaths: state.images.map((e) => e.path).toList(),
                  currentIndex: state.currentIndex,
                  scrollController: _scrollController,
                  onImageTap: (index) {
                    context.read<ImageViewerBloc>().add(GoToIndex(index));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: AppTheme.emptyStateDecoration,
        child: TextButton(
          onPressed: () async {
            // TODO: Implement file picker
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(AppConstants.paddingXLarge),
                child: Image.asset(
                  AppConstants.appIconPath,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 50, color: Colors.white);
                  },
                ),
              ),
              const Text(
                'Open Image',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final state = context.read<ImageViewerBloc>().state;
    if (state.currentImage == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.buttonBackground,
        title: Text(
          'Delete "${state.currentImage!.title}"',
          overflow: TextOverflow.ellipsis,
          style: AppTheme.dialogTitleStyle,
        ),
        content: Text(
          'This image will be deleted permanently. Are you sure?',
          style: AppTheme.dialogContentStyle,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ImageViewerBloc>().add(const DeleteCurrent());
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: AppTheme.buttonTextStyle),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }
}