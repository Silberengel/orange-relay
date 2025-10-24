// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_structure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookStructure _$BookStructureFromJson(Map<String, dynamic> json) =>
    BookStructure(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      author: json['author'] as String,
      created_at: (json['created_at'] as num).toInt(),
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      total_chapters: (json['total_chapters'] as num).toInt(),
      current_chapter: (json['current_chapter'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BookStructureToJson(BookStructure instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'description': instance.description,
      'author': instance.author,
      'created_at': instance.created_at,
      'chapters': instance.chapters,
      'metadata': instance.metadata,
      'total_chapters': instance.total_chapters,
      'current_chapter': instance.current_chapter,
    };

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      order: (json['order'] as num).toInt(),
      summary: json['summary'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      word_count: (json['word_count'] as num).toInt(),
      reading_time_minutes: (json['reading_time_minutes'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'order': instance.order,
      'summary': instance.summary,
      'tags': instance.tags,
      'word_count': instance.word_count,
      'reading_time_minutes': instance.reading_time_minutes,
      'metadata': instance.metadata,
    };

BookMetadata _$BookMetadataFromJson(Map<String, dynamic> json) => BookMetadata(
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      language: json['language'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      cover_image: json['cover_image'] as String?,
      license: json['license'] as String?,
      custom_fields: json['custom_fields'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BookMetadataToJson(BookMetadata instance) =>
    <String, dynamic>{
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'language': instance.language,
      'genres': instance.genres,
      'cover_image': instance.cover_image,
      'license': instance.license,
      'custom_fields': instance.custom_fields,
    };
