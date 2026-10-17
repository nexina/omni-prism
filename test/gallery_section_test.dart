import 'package:flutter_test/flutter_test.dart';
import 'package:omni_prism/features/gallery/domain/entities/gallery_section.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

void main() {
  ImageItem image(String path, [DateTime? modified]) =>
      ImageItem(path: path, modified: modified);

  final images = [
    image('/home/me/Pictures/b.png', DateTime(2025, 3, 2)),
    image('/home/me/Pictures/Trip/a.png', DateTime(2026, 10, 1)),
    image('/home/me/Pictures/c.png'),
    image('/home/me/Pictures/Trip/d.png', DateTime(2026, 9, 30)),
    image('/home/me/Pictures/e.png', DateTime(2026, 10, 5)),
  ];

  List<String> titles(List<GallerySection> sections) => [
        for (final s in sections)
          '${s.title}: ${s.images.map((i) => i.path.split('/').last).join(', ')}',
      ];

  test('groups by folder relative to the added root, keeping scan order', () {
    final sections = GallerySection.group(images, GalleryGrouping.folder,
        rootFolders: ['/home/me/Pictures']);
    expect(titles(sections), [
      'Pictures: b.png, c.png, e.png',
      'Pictures/Trip: a.png, d.png',
    ]);
  });

  test('groups by month newest first, undated last', () {
    expect(titles(GallerySection.group(images, GalleryGrouping.month)), [
      'October 2026: e.png, a.png',
      'September 2026: d.png',
      'March 2025: b.png',
      'Unknown date: c.png',
    ]);
  });

  test('groups by year newest first', () {
    expect(titles(GallerySection.group(images, GalleryGrouping.year)), [
      '2026: e.png, a.png, d.png',
      '2025: b.png',
      'Unknown date: c.png',
    ]);
  });

  test('take keeps the first images in display order and full counts', () {
    final sections = GallerySection.take(
        GallerySection.group(images, GalleryGrouping.month), 3);
    expect(titles(sections), ['October 2026: e.png, a.png', 'September 2026: d.png']);
    expect(sections.first.totalCount, 2);

    final partial = GallerySection.take(
        GallerySection.group(images, GalleryGrouping.year), 2);
    expect(titles(partial), ['2026: e.png, a.png']);
    expect(partial.single.totalCount, 3);
  });
}
