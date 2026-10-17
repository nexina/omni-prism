import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// How the gallery groups its images
enum GalleryGrouping {
  folder('Folder'),
  month('Month'),
  year('Year');

  final String label;

  const GalleryGrouping(this.label);
}

/// A titled group of gallery images
class GallerySection {
  final String title;
  final List<ImageItem> images;

  final int? _totalCount;

  const GallerySection({
    required this.title,
    required this.images,
    int? totalCount,
  }) : _totalCount = totalCount;

  /// Images in the whole section, including ones not shown yet
  int get totalCount => _totalCount ?? images.length;

  /// Groups [images] by [grouping].
  ///
  /// Folders are sorted by path, shown relative to the added folder in
  /// [rootFolders] that contains them, and keep their images in scan order.
  /// Months and years are newest first, with their images newest first;
  /// images without a modified time go last.
  static List<GallerySection> group(
    List<ImageItem> images,
    GalleryGrouping grouping, {
    List<String> rootFolders = const [],
  }) {
    if (grouping == GalleryGrouping.folder) {
      final byFolder = <String, List<ImageItem>>{};
      for (final image in images) {
        byFolder.putIfAbsent(p.dirname(image.path), () => []).add(image);
      }
      final folders = byFolder.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return [
        for (final folder in folders)
          GallerySection(
            title: _folderTitle(folder, rootFolders),
            images: byFolder[folder]!,
          ),
      ];
    }

    final sorted = [...images]..sort(_newestFirst);
    final format = grouping == GalleryGrouping.month
        ? DateFormat('MMMM yyyy')
        : DateFormat('yyyy');
    final sections = <GallerySection>[];
    String? currentTitle;
    for (final image in sorted) {
      final modified = image.modified;
      final title = modified == null ? 'Unknown date' : format.format(modified);
      if (title != currentTitle) {
        sections.add(GallerySection(title: title, images: []));
        currentTitle = title;
      }
      sections.last.images.add(image);
    }
    return sections;
  }

  /// The first [count] images of [sections], in display order
  static List<GallerySection> take(List<GallerySection> sections, int count) {
    final result = <GallerySection>[];
    var remaining = count;
    for (final section in sections) {
      if (remaining <= 0) break;
      if (section.images.length <= remaining) {
        result.add(section);
      } else {
        result.add(GallerySection(
          title: section.title,
          images: section.images.sublist(0, remaining),
          totalCount: section.totalCount,
        ));
      }
      remaining -= section.images.length;
    }
    return result;
  }

  static int _newestFirst(ImageItem a, ImageItem b) {
    final am = a.modified, bm = b.modified;
    if (am == null) return bm == null ? 0 : 1;
    if (bm == null) return -1;
    return bm.compareTo(am);
  }

  /// The folder's path from its added root, e.g. "Pictures/2024/Trip"
  static String _folderTitle(String folder, List<String> rootFolders) {
    for (final root in rootFolders) {
      if (p.equals(root, folder) || p.isWithin(root, folder)) {
        return p.relative(folder, from: p.dirname(root));
      }
    }
    return folder;
  }
}
