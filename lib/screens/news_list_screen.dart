import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

/// Main screen displaying the list of news articles
/// Features: pull-to-refresh, search, category filtering, and loading states
class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load news when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadNews();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildNewsList()),
        ],
      ),
    );
  }

  /// Builds the app bar with title and search functionality
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Berita Terkini',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Consumer<NewsProvider>(
          builder: (context, newsProvider, child) {
            return IconButton(
              icon: Icon(
                newsProvider.searchQuery.isEmpty 
                    ? Icons.search 
                    : Icons.clear,
              ),
              onPressed: () {
                if (newsProvider.searchQuery.isEmpty) {
                  // Focus on search bar
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  // Clear search
                  _searchController.clear();
                  newsProvider.clearSearch();
                }
              },
            );
          },
        ),
      ],
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari berita...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<NewsProvider>().clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          // Debounce search to avoid too many API calls
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              context.read<NewsProvider>().searchArticles(value);
            }
          });
        },
      ),
    );
  }

  /// Builds the category filter chips
  Widget _buildCategoryFilter() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading || newsProvider.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: newsProvider.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = newsProvider.categories[index];
              final isSelected = category == newsProvider.selectedCategory;

              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  newsProvider.filterByCategory(category);
                },
                selectedColor: Theme.of(context).primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds the main news list with different states
  Widget _buildNewsList() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // Loading state
        if (newsProvider.isLoading && !newsProvider.hasData) {
          return _buildLoadingState();
        }

        // Error state
        if (newsProvider.hasError && !newsProvider.hasData) {
          return _buildErrorState(newsProvider);
        }

        // Empty state
        if (newsProvider.articles.isEmpty) {
          return _buildEmptyState();
        }

        // Success state with data
        return RefreshIndicator(
          onRefresh: newsProvider.refreshNews,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: newsProvider.articles.length,
            itemBuilder: (context, index) {
              final article = newsProvider.articles[index];
              return NewsCard(
                article: article,
                onTap: () => _navigateToDetail(article.id),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds the loading state UI
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat berita...'),
        ],
      ),
    );
  }

  /// Builds the error state UI
  Widget _buildErrorState(NewsProvider newsProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi kesalahan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              newsProvider.errorMessage ?? 'Gagal memuat berita',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: newsProvider.retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada berita ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah kata kunci pencarian atau filter kategori',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the news detail screen
  void _navigateToDetail(String articleId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(articleId: articleId),
      ),
    );
  }
}
