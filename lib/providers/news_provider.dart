import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

/// Provider class for managing news state
/// Uses ChangeNotifier for reactive state management
/// Handles loading states, error states, and data caching
class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  
  // Private state variables
  List<NewsArticle> _articles = [];
  List<NewsArticle> _filteredArticles = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Public getters for accessing state
  List<NewsArticle> get articles => _filteredArticles.isEmpty && _searchQuery.isEmpty 
      ? _articles 
      : _filteredArticles;
  
  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasError => _errorMessage != null;
  bool get hasData => _articles.isNotEmpty;

  /// Loads all news articles from the service
  /// Sets loading state and handles errors appropriately
  Future<void> loadNews() async {
    _setLoading(true);
    _clearError();
    
    try {
      _articles = await _newsService.fetchAllNews();
      _categories = await _newsService.getCategories();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load news: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the news data
  /// Useful for pull-to-refresh functionality
  Future<void> refreshNews() async {
    _clearError();
    await loadNews();
  }

  /// Filters articles by category
  /// Updates the UI to show only articles in the selected category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Searches articles by query string
  /// Updates the filtered articles based on search results
  Future<void> searchArticles(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _applyFilters();
    } else {
      _setLoading(true);
      try {
        _filteredArticles = await _newsService.searchNews(_searchQuery);
      } catch (e) {
        _setError('Search failed: ${e.toString()}');
      } finally {
        _setLoading(false);
      }
    }
    
    notifyListeners();
  }

  /// Clears the current search and resets filters
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  /// Gets a specific article by ID
  /// Returns null if article is not found
  NewsArticle? getArticleById(String id) {
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Applies current filters (category and search) to the articles
  void _applyFilters() {
    if (_searchQuery.isNotEmpty) {
      // Search is active, don't apply category filter
      return;
    }
    
    if (_selectedCategory == 'All') {
      _filteredArticles = List.from(_articles);
    } else {
      _filteredArticles = _articles
          .where((article) => article.category == _selectedCategory)
          .toList();
    }
  }

  /// Sets the loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets an error message and notifies listeners
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the current error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Retries loading news after an error
  Future<void> retry() async {
    await loadNews();
  }
}
