import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/app_providers.dart';
import '../models/book_structure.dart';
import '../widgets/chapter_navigation.dart';
import '../widgets/reading_progress.dart';

class BookReaderScreen extends ConsumerStatefulWidget {
  final String bookId;

  const BookReaderScreen({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNavigation = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Hide navigation when scrolling
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset > 100 && _showNavigation) {
        setState(() {
          _showNavigation = false;
        });
      }
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChapterNavigation(
        book: ref.read(bookProvider(widget.bookId).notifier).state.value,
        onChapterSelected: (chapter) {
          Navigator.pop(context);
          _navigateToChapter(chapter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookProvider(widget.bookId));

    return Scaffold(
      appBar: _isFullscreen ? null : AppBar(
        title: bookAsync.when(
          data: (book) => Text(book?.title ?? 'Loading...'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showChapterList,
          ),
          IconButton(
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Book not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Reading progress
                  ReadingProgress(
                    currentChapter: book.current_chapter,
                    totalChapters: book.total_chapters,
                    progress: book.readingProgress,
                  ),
                  
                  // Chapter content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chapter title
                          Text(
                            book.currentChapter?.title ?? 'No Chapter',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          
                          // Chapter content
                          MarkdownBody(
                            data: book.currentChapter?.content ?? 'No content available',
                            styleSheet: MarkdownStyleSheet(
                              p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                              ),
                              h1: Theme.of(context).textTheme.headlineMedium,
                              h2: Theme.of(context).textTheme.headlineSmall,
                              h3: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Navigation overlay
              if (_showNavigation)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: book.current_chapter > 0
                              ? () {
                                  _goToPreviousChapter();
                                }
                              : null,
                        ),
                        Text(
                          'Chapter ${book.current_chapter + 1} of ${book.total_chapters}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: book.current_chapter < book.total_chapters - 1
                              ? () {
                                  _goToNextChapter();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading book',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[700],
                ),
              ),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(bookProvider(widget.bookId).notifier).loadBook();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showNavigation = !_showNavigation;
          });
        },
        child: const Icon(Icons.menu),
      ),
    );
  }

  void _navigateToChapter(Chapter chapter) {
    // Update the current chapter in the book
    ref.read(bookProvider(widget.bookId).notifier).setCurrentChapter(chapter.index);
  }

  void _goToPreviousChapter() {
    final book = ref.read(bookProvider(widget.bookId).notifier).state.value;
    if (book.current_chapter > 0) {
      final previousChapter = book.chapters[book.current_chapter - 1];
      _navigateToChapter(previousChapter);
    }
  }

  void _goToNextChapter() {
    final book = ref.read(bookProvider(widget.bookId).notifier).state.value;
    if (book.current_chapter < book.total_chapters - 1) {
      final nextChapter = book.chapters[book.current_chapter + 1];
      _navigateToChapter(nextChapter);
    }
  }
}
