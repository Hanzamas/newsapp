import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/news_article.dart';

/// Service class responsible for fetching news data
/// This demonstrates fetching data from external sources (local JSON file)
/// In a real app, this would typically make HTTP requests to an API
class NewsService {
  static const String _dataPath = 'assets/data/news_data.json';

  /// Fetches all news articles from the data source
  /// Returns a list of NewsArticle objects
  /// Throws an exception if data cannot be loaded
  Future<List<NewsArticle>> fetchAllNews() async {
    try {
      // Simulate network delay for realistic behavior
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Load JSON data from assets
      final String jsonString = await rootBundle.loadString(_dataPath);
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // Convert JSON to NewsArticle objects
      final List<NewsArticle> articles = jsonData
          .map((json) => NewsArticle.fromJson(json))
          .toList();
      
      // Sort articles by published date (newest first)
      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      
      return articles;
    } catch (e) {
      throw Exception('Failed to load news data: $e');
    }
  }

  /// Fetches a specific news article by ID
  /// Returns the NewsArticle if found, null otherwise
  Future<NewsArticle?> fetchNewsById(String id) async {
    try {
      final List<NewsArticle> allNews = await fetchAllNews();
      return allNews.firstWhere(
        (article) => article.id == id,
        orElse: () => throw Exception('Article not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetches news articles filtered by category
  /// Returns a list of NewsArticle objects in the specified category
  Future<List<NewsArticle>> fetchNewsByCategory(String category) async {
    try {
      final List<NewsArticle> allNews = await fetchAllNews();
      return allNews
          .where((article) => 
              article.category.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      throw Exception('Failed to load news by category: $e');
    }
  }

  /// Searches for news articles by title or content
  /// Returns a list of NewsArticle objects that match the search query
  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      final List<NewsArticle> allNews = await fetchAllNews();
      final String lowercaseQuery = query.toLowerCase();
      
      return allNews.where((article) =>
        article.title.toLowerCase().contains(lowercaseQuery) ||
        article.summary.toLowerCase().contains(lowercaseQuery) ||
        article.content.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }

  /// Gets all unique categories from the news data
  /// Returns a list of category strings
  Future<List<String>> getCategories() async {
    try {
      final List<NewsArticle> allNews = await fetchAllNews();
      final Set<String> categories = allNews
          .map((article) => article.category)
          .toSet();
      
      final List<String> sortedCategories = categories.toList()..sort();
      return sortedCategories;
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
