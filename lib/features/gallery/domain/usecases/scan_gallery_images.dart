import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Use case for scanning a folder tree for images in the background
class ScanGalleryImagesUseCase {
  final GalleryRepository _repository;

  ScanGalleryImagesUseCase(this._repository);

  /// Emits batches of images as they are found
  Stream<List<ImageItem>> call(String folderPath) {
    return _repository.scanImages(folderPath);
  }

  /// Scans [folders] in parallel, each on its own isolate, running at most
  /// [concurrency] at once (by default one per spare CPU core, up to 4).
  /// Batches are emitted as soon as any scan finds them; cancelling the
  /// subscription stops every running scan.
  Stream<List<ImageItem>> scanAll(List<String> folders, {int? concurrency}) {
    final limit = max(1, concurrency ?? min(4, Platform.numberOfProcessors - 1));
    final pending = [...folders];
    final running = <StreamSubscription<List<ImageItem>>>{};
    late final StreamController<List<ImageItem>> controller;

    void startNext() {
      while (running.length < limit && pending.isNotEmpty) {
        late final StreamSubscription<List<ImageItem>> subscription;
        subscription = call(pending.removeAt(0)).listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            running.remove(subscription);
            startNext();
          },
        );
        running.add(subscription);
      }
      if (running.isEmpty && pending.isEmpty && !controller.isClosed) {
        controller.close();
      }
    }

    controller = StreamController<List<ImageItem>>(
      onListen: startNext,
      onPause: () {
        for (final s in running) {
          s.pause();
        }
      },
      onResume: () {
        for (final s in running) {
          s.resume();
        }
      },
      onCancel: () async {
        pending.clear();
        final subscriptions = [...running];
        running.clear();
        await Future.wait(subscriptions.map((s) => s.cancel()));
      },
    );
    return controller.stream;
  }

  /// Returns the paths among [paths] whose files no longer exist
  Future<Set<String>> findMissing(List<String> paths) {
    return _repository.findMissing(paths);
  }
}
