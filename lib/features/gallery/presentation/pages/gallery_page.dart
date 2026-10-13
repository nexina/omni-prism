import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/core/class/working_file.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/file_types.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/utils/path_utils.dart';
import 'package:omni_prism/core/widgets/index.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:omni_prism/features/gallery/presentation/widgets/gallery_grid.dart';

/// Main gallery page
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GalleryBloc>()..add(const LoadGallery()),
      child: const _GalleryPageView(),
    );
  }
}

class _GalleryPageView extends StatelessWidget {
  const _GalleryPageView();

  @override
  Widget build(BuildContext context) {
    return BackgroundBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GalleryHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: BlocBuilder<GalleryBloc, GalleryState>(
                  builder: (context, state) {
                    final bloc = context.read<GalleryBloc>();
                    switch (state.status) {
                      case GalleryStatus.initial:
                      case GalleryStatus.loading:
                        return const GalleryLoadingState();
                      case GalleryStatus.empty:
                        return GalleryEmptyState(
                          message:
                              'No images found in "${_folderName(state.folderPath)}"',
                          onPickFolder: () => bloc.add(const PickCustomFolder()),
                        );
                      case GalleryStatus.error:
                        return GalleryErrorState(
                          error: state.error ?? 'Unknown error',
                          onRetry: () => bloc.add(const RefreshGallery()),
                        );
                      case GalleryStatus.loaded:
                        return GalleryGrid(
                          images: state.images,
                          onImageTap: (index) => bloc.add(SelectImage(index)),
                        );
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const OmniFooter(),
        ],
      ),
    );
  }

  static String _folderName(String path) {
    if (path.isEmpty) return 'Gallery';
    return PathUtils.getFileName(path);
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader();

  Future<void> _openFile(BuildContext context) async {
    const typeGroup = XTypeGroup(
      label: 'Images',
      extensions: FileTypes.images,
    );
    final picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) return;

    int size = 0;
    try {
      size = await File(picked.path).length();
    } catch (_) {}

    AppRouter.navigateToImageViewer(
      WorkingFile(path: picked.path, workingPath: picked.path, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<GalleryBloc, GalleryState>(
              buildWhen: (prev, curr) =>
                  prev.folderPath != curr.folderPath ||
                  prev.images.length != curr.images.length,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                    if (state.folderPath.isNotEmpty)
                      Text(
                        '${state.folderPath}  ·  ${state.images.length} images',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                context.read<GalleryBloc>().add(const RefreshGallery()),
          ),
          const SizedBox(width: 8),
          _WhiteButton(
            label: 'Open Folder',
            onPressed: () =>
                context.read<GalleryBloc>().add(const PickCustomFolder()),
          ),
          const SizedBox(width: 12),
          _WhiteButton(
            label: 'Open File',
            onPressed: () => _openFile(context),
          ),
        ],
      ),
    );
  }
}

/// White pill button matching the Omni style
class _WhiteButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _WhiteButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 38,
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
