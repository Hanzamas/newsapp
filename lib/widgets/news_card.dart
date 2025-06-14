import 'package:flutter/material.dart';
import '../models/news_article.dart';

/// Reusable widget for displaying a news article card
/// Shows article thumbnail, title, summary, author, and date
/// Handles tap events for navigation to detail screen
class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            _buildArticleImage(),
            
            // Article content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  _buildCategoryBadge(),
                  
                  const SizedBox(height: 8),
                  
                  // Article title
                  _buildTitle(context),
                  
                  const SizedBox(height: 8),
                  
                  // Article summary
                  _buildSummary(context),
                  
                  const SizedBox(height: 12),
                  
                  // Author and date
                  _buildMetadata(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the article image with error handling
  Widget _buildArticleImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: Image.network(
          article.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the category badge
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        article.category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds the article title
  Widget _buildTitle(BuildContext context) {
    return Text(
      article.title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the article summary
  Widget _buildSummary(BuildContext context) {
    return Text(
      article.summary,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the metadata row with author and date
  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            article.author,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(article.publishedAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Gets color for category badge based on category
  Color _getCategoryColor() {
    switch (article.category.toLowerCase()) {
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
    final Duration difference = DateTime.now().difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}h lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
  }
}
