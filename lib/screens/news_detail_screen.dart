import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../models/news_article.dart';

/// Detail screen for displaying a single news article
/// Shows full article content with proper formatting and navigation
class NewsDetailScreen extends StatelessWidget {
  final String articleId;

  const NewsDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final article = newsProvider.getArticleById(articleId);

          if (article == null) {
            return _buildNotFoundState(context);
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, article),
              SliverToBoxAdapter(
                child: _buildArticleContent(context, article),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the sliver app bar with article image and title
  Widget _buildSliverAppBar(BuildContext context, NewsArticle article) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            article.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              article.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareArticle(article),
        ),
      ],
    );
  }

  /// Builds the main article content
  Widget _buildArticleContent(BuildContext context, NewsArticle article) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and metadata
          _buildArticleMetadata(context, article),
          
          const SizedBox(height: 16),
          
          // Article title (repeated for better readability)
          _buildArticleTitle(context, article),
          
          const SizedBox(height: 12),
          
          // Article summary
          _buildArticleSummary(context, article),
          
          const SizedBox(height: 20),
          
          // Divider
          const Divider(),
          
          const SizedBox(height: 20),
          
          // Article content
          _buildArticleFullContent(context, article),
          
          const SizedBox(height: 32),
          
          // Author info
          _buildAuthorInfo(context, article),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds the article metadata (category, date, etc.)
  Widget _buildArticleMetadata(BuildContext context, NewsArticle article) {
    return Row(
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCategoryColor(article.category),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            article.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const Spacer(),
        
        // Published date
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(article.publishedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the article title
  Widget _buildArticleTitle(BuildContext context, NewsArticle article) {
    return Text(
      article.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    );
  }

  /// Builds the article summary
  Widget _buildArticleSummary(BuildContext context, NewsArticle article) {
    return Text(
      article.summary,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.grey[700],
        height: 1.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  /// Builds the full article content
  Widget _buildArticleFullContent(BuildContext context, NewsArticle article) {
    // Split content into paragraphs for better readability
    final paragraphs = article.content.split('\n\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        if (paragraph.trim().isEmpty) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            paragraph.trim(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),
        );
      }).toList(),
    );
  }

  /// Builds the author information section
  Widget _buildAuthorInfo(BuildContext context, NewsArticle article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              article.author.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.author,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Penulis',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the not found state when article doesn't exist
  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Artikel tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Artikel yang Anda cari mungkin telah dihapus atau dipindahkan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets color for category badge
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'teknologi':
        return Colors.blue;
      case 'ekonomi':
        return Colors.green;
      case 'sains':
        return Colors.purple;
      case 'kuliner':
        return Colors.orange;
      case 'olahraga':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Formats the date for display
  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Handles sharing the article
  void _shareArticle(NewsArticle article) {
    // In a real app, you would use the share_plus package
    // For now, we'll show a simple dialog
    // Share.share('${article.title}\n\n${article.summary}');
  }
}
