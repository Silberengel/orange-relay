import 'package:flutter/material.dart';
import '../models/book_structure.dart';

class ChapterNavigation extends StatelessWidget {
  final BookStructure? book;
  final Function(Chapter)? onChapterSelected;

  const ChapterNavigation({
    super.key,
    this.book,
    this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: book?.chapters.isEmpty ?? true
                ? const Center(
                    child: Text('No chapters available'),
                  )
                : ListView.builder(
                    itemCount: book!.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = book!.chapters[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(chapter.title),
                        subtitle: Text(
                          '${chapter.reading_time_minutes} min read',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          onChapterSelected?.call(chapter);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
