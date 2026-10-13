import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/core/class/working_file.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/config/file_types.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/utils/format_utils.dart';
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
          const _FolderChips(),
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
                          message: state.hasFolders
                              ? 'No images found in the added folders'
                              : 'Add a folder to see its images here.\n'
                                  'Nothing is scanned until you add one.',
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
                  prev.folders != curr.folders ||
                  prev.images.length != curr.images.length ||
                  prev.isLoading != curr.isLoading,
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
                    if (state.hasFolders)
                      Row(
                        children: [
                          if (state.isLoading) ...[
                            const SizedBox.square(
                              dimension: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              '${FormatUtils.formatNumber(state.imageCount)} images'
                              ' in ${state.folders.length} '
                              '${state.folders.length == 1 ? 'folder' : 'folders'}'
                              '${state.isLoading ? '  ·  scanning…' : ''}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
          BlocSelector<GalleryBloc, GalleryState, bool>(
            selector: (state) => state.hasFolders,
            builder: (context, hasFolders) => IconButton(
              tooltip: 'Rescan',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: hasFolders
                  ? () => context.read<GalleryBloc>().add(const RefreshGallery())
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          _WhiteButton(
            label: 'Add Folder',
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

/// Removable chips for the folders added to the gallery
class _FolderChips extends StatelessWidget {
  const _FolderChips();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GalleryBloc, GalleryState, List<String>>(
      selector: (state) => state.folders,
      builder: (context, folders) {
        if (folders.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 12.0, right: 24.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final folder in folders)
                Tooltip(
                  message: folder,
                  child: InputChip(
                    avatar: const Icon(Icons.folder, size: 16, color: Colors.white),
                    label: Text(
                      PathUtils.getFileName(folder),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: AppConstants.fontFamily,
                      ),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    side: const BorderSide(color: Colors.white54),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteIconColor: Colors.white70,
                    deleteButtonTooltipMessage: 'Remove folder',
                    onDeleted: () =>
                        context.read<GalleryBloc>().add(RemoveFolder(folder)),
                  ),
                ),
            ],
          ),
        );
      },
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
