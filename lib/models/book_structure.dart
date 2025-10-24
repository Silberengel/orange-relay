import 'package:json_annotation/json_annotation.dart';

part 'book_structure.g.dart';

@JsonSerializable()
class BookStructure {
  final String id;
  final String title;
  final String? summary;
  final String? description;
  final String author;
  final int created_at;
  final List<Chapter> chapters;
  final Map<String, dynamic>? metadata;
  final int total_chapters;
  final int current_chapter;

  const BookStructure({
    required this.id,
    required this.title,
    this.summary,
    this.description,
    required this.author,
    required this.created_at,
    required this.chapters,
    this.metadata,
    required this.total_chapters,
    this.current_chapter = 0,
  });

  factory BookStructure.fromJson(Map<String, dynamic> json) => _$BookStructureFromJson(json);
  Map<String, dynamic> toJson() => _$BookStructureToJson(this);

  /// Get current chapter
  Chapter? get currentChapter {
    if (chapters.isEmpty || current_chapter >= chapters.length) return null;
    return chapters[current_chapter];
  }

  /// Get reading progress percentage
  double get readingProgress {
    if (total_chapters == 0) return 0.0;
    return (current_chapter / total_chapters) * 100;
  }

  /// Get estimated reading time
  String get estimatedReadingTime {
    final totalWords = chapters.fold<int>(0, (sum, chapter) => sum + chapter.word_count);
    final wordsPerMinute = 200; // Average reading speed
    final minutes = (totalWords / wordsPerMinute).ceil();
    
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

@JsonSerializable()
class Chapter {
  final String id;
  final String title;
  final String content;
  final int order;
  final String? summary;
  final List<String>? tags;
  final int word_count;
  final int reading_time_minutes;
  final Map<String, dynamic>? metadata;

  const Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    this.summary,
    this.tags,
    required this.word_count,
    required this.reading_time_minutes,
    this.metadata,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterToJson(this);

  /// Get content preview (first 200 characters)
  String get contentPreview {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }

  /// Get chapter index (same as order)
  int get index => order;

  /// Get reading time as string
  String get readingTimeString {
    if (reading_time_minutes < 1) return '< 1m';
    if (reading_time_minutes < 60) return '${reading_time_minutes}m';
    final hours = reading_time_minutes ~/ 60;
    final minutes = reading_time_minutes % 60;
    return '${hours}h ${minutes}m';
  }
}

@JsonSerializable()
class BookMetadata {
  final String? isbn;
  final String? publisher;
  final String? language;
  final List<String>? genres;
  final String? cover_image;
  final String? license;
  final Map<String, dynamic>? custom_fields;

  const BookMetadata({
    this.isbn,
    this.publisher,
    this.language,
    this.genres,
    this.cover_image,
    this.license,
    this.custom_fields,
  });

  factory BookMetadata.fromJson(Map<String, dynamic> json) => _$BookMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$BookMetadataToJson(this);
}
