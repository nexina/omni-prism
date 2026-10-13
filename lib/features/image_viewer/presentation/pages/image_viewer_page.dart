import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/core/class/working_file.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/theme.dart';
import 'package:omni_prism/core/utils/format_utils.dart';
import 'package:omni_prism/core/utils/path_utils.dart';
import 'package:omni_prism/core/widgets/index.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_bloc.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_event.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_state.dart';
import 'package:omni_prism/features/image_viewer/presentation/widgets/index.dart';

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

class _ImageViewerPageState extends State<ImageViewerPage> {
  PageController? _pageController;
  bool _isZoomed = false;

  // share_plus cannot share files on Linux
  static bool get _canShare => !Platform.isLinux;

  @override
  void initState() {
    super.initState();
    final path = widget.workingFile.workingPath;
    context.read<ImageViewerBloc>().add(
          LoadImages(
            folderPath: PathUtils.getDirectoryPath(path),
            initialPath: path,
          ),
        );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// Keeps the PageView in step with the bloc's current index
  void _syncPage(int index) {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    final page = controller.page?.round() ?? controller.initialPage;
    if (page == index) return;
    if ((page - index).abs() == 1) {
      controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      controller.jumpToPage(index);
    }
  }

  void _onStateChanged(BuildContext context, ImageViewerState state) {
    _syncPage(state.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ImageViewerBloc, ImageViewerState>(
          listenWhen: (prev, curr) =>
              prev.currentIndex != curr.currentIndex ||
              prev.images.length != curr.images.length,
          listener: _onStateChanged,
        ),
        BlocListener<ImageViewerBloc, ImageViewerState>(
          listenWhen: (prev, curr) =>
              curr.error != null &&
              prev.error != curr.error &&
              curr.status == ImageViewerStatus.loaded,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          },
        ),
      ],
      child: BlocBuilder<ImageViewerBloc, ImageViewerState>(
        builder: (context, state) {
          switch (state.status) {
            case ImageViewerStatus.initial:
            case ImageViewerStatus.loading:
              return const BackgroundBuilder(
                transparent: true,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            case ImageViewerStatus.empty:
              return _buildMessage(
                icon: Icons.image_not_supported_outlined,
                message: 'No images left in this folder',
              );
            case ImageViewerStatus.error:
              return _buildMessage(
                icon: Icons.error_outline,
                message: 'Error: ${state.error}',
              );
            case ImageViewerStatus.loaded:
              if (state.currentImage == null) {
                return _buildMessage(
                  icon: Icons.image_not_supported_outlined,
                  message: 'Nothing to show',
                );
              }
              return _buildViewer(context, state);
          }
        },
      ),
    );
  }

  Widget _buildMessage({required IconData icon, required String message}) {
    return BackgroundBuilder(
      transparent: true,
      child: Column(
        children: [
          ViewerAppBar(title: PathUtils.getFileName(widget.workingFile.path)),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const OmniFooter(),
        ],
      ),
    );
  }

  Widget _buildViewer(BuildContext context, ImageViewerState state) {
    final bloc = context.read<ImageViewerBloc>();
    final image = state.currentImage!;
    final showChrome = state.isVisible && !state.isFullscreen;
    _pageController ??= PageController(initialPage: state.currentIndex);

    final details = <String>[
      '${state.displayIndex} / ${state.totalImages}',
      if (image.creationTime.isNotEmpty) image.creationTime,
      if (image.size != null) FormatUtils.formatBytes(image.size!),
    ].join('  ·  ');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            bloc.add(const NavigateNext()),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            bloc.add(const NavigatePrev()),
        const SingleActivator(LogicalKeyboardKey.delete): () =>
            _showDeleteDialog(context),
        const SingleActivator(LogicalKeyboardKey.keyF): () =>
            bloc.add(const ToggleFullscreen()),
        const SingleActivator(LogicalKeyboardKey.f11): () =>
            bloc.add(const ToggleFullscreen()),
        const SingleActivator(LogicalKeyboardKey.keyI): () =>
            _showInfoDialog(context, image),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (state.isFullscreen) {
            bloc.add(const ToggleFullscreen());
          } else {
            Navigator.of(context).maybePop();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: BackgroundBuilder(
          transparent: true,
          overlayOpacity: showChrome ? 0.5 : 0.85,
          child: Column(
            children: [
              if (showChrome)
                ViewerAppBar(
                  title: image.title,
                  desc: details,
                  actions: _buildActions(context, state),
                ),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: _isZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      itemCount: state.images.length,
                      onPageChanged: (index) {
                        if (index != bloc.state.currentIndex) {
                          bloc.add(GoToIndex(index));
                        }
                      },
                      itemBuilder: (context, index) {
                        final item = state.images[index];
                        return ZoomableImage(
                          key: ValueKey(item.path),
                          imagePath: item.path,
                          onTap: () => bloc.add(const ToggleVisibility()),
                          onZoomChanged: (zoomed) {
                            if (zoomed != _isZoomed) {
                              setState(() => _isZoomed = zoomed);
                            }
                          },
                        );
                      },
                    ),
                    if (state.hasPrev)
                      _NavigationButton(
                        icon: Icons.chevron_left,
                        alignment: Alignment.centerLeft,
                        tooltip: 'Previous',
                        onPressed: () => bloc.add(const NavigatePrev()),
                      ),
                    if (state.hasNext)
                      _NavigationButton(
                        icon: Icons.chevron_right,
                        alignment: Alignment.centerRight,
                        tooltip: 'Next',
                        onPressed: () => bloc.add(const NavigateNext()),
                      ),
                  ],
                ),
              ),
              if (showChrome && state.totalImages > 1)
                ImageOverview(
                  imagePaths: state.images.map((e) => e.path).toList(),
                  currentIndex: state.currentIndex,
                  onImageTap: (index) => bloc.add(GoToIndex(index)),
                ),
              if (showChrome) const OmniFooter(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ImageViewerState state) {
    final bloc = context.read<ImageViewerBloc>();
    return [
      if (_canShare)
        _ActionButton(
          icon: Icons.share,
          tooltip: 'Share',
          onPressed: () => bloc.add(const ShareCurrent()),
        ),
      _ActionButton(
        icon: Icons.info_outline,
        tooltip: 'Information (I)',
        onPressed: () => _showInfoDialog(context, state.currentImage!),
      ),
      _ActionButton(
        icon: state.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        tooltip: 'Fullscreen (F)',
        onPressed: () => bloc.add(const ToggleFullscreen()),
      ),
      _ActionButton(
        icon: Icons.delete_outline,
        tooltip: 'Delete (Del)',
        onPressed: () => _showDeleteDialog(context),
      ),
    ];
  }

  void _showInfoDialog(BuildContext context, ImageItem image) {
    final rows = <(String, String)>[
      ('Name', image.title),
      ('Folder', PathUtils.getDirectoryPath(image.path)),
      ('Type', PathUtils.getExtension(image.path).toUpperCase()),
      if (image.size != null) ('Size', FormatUtils.formatBytes(image.size!)),
      if (image.creationTime.isNotEmpty) ('Modified', image.creationTime),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Information', style: AppTheme.dialogTitleStyle),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          label,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          value,
                          style: AppTheme.dialogContentStyle,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    // Read the bloc here: the dialog route is outside this page's BlocProvider
    final bloc = context.read<ImageViewerBloc>();
    final image = bloc.state.currentImage;
    if (image == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete "${image.title}"',
          overflow: TextOverflow.ellipsis,
          style: AppTheme.dialogTitleStyle,
        ),
        content: const Text(
          'This image will be deleted permanently. Are you sure?',
          style: AppTheme.dialogContentStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: AppTheme.buttonTextStyle),
          ),
          TextButton(
            onPressed: () {
              bloc.add(const DeleteCurrent());
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Delete',
              style: AppTheme.buttonTextStyle.copyWith(
                color: const Color.fromARGB(255, 255, 137, 129),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// App bar action icon
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

/// Round previous/next button floating over the image
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final Alignment alignment;
  final String tooltip;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    required this.alignment,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Material(
          color: Colors.black.withValues(alpha: 0.4),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 32),
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
