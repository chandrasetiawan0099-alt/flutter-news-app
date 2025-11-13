import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/news_model.dart';

class NewsService {
  static const String _apiKey = '8d91d42d82cf41ada160e94b1eeaa494';
  static const String _base = 'https://newsapi.org/v2/top-headlines';

  static List<Map<String, String>> getCategories() {
    return [
      {'key': 'general', 'label': 'Home'},
      {'key': 'business', 'label': 'Business'},
      {'key': 'entertainment', 'label': 'Entertainment'},
      {'key': 'health', 'label': 'Health'},
      {'key': 'science', 'label': 'Science'},
      {'key': 'sports', 'label': 'Sports'},
      {'key': 'technology', 'label': 'Technology'},
    ];
  }

  Future<List<NewsModel>> fetchTopHeadlines({
    String country = 'us',
    int pageSize = 25,
    String? category,
    String? q, // <-- search query (optional)
  }) async {
    final params = <String, String>{
      'country': country,
      'pageSize': pageSize.toString(),
      'apiKey': _apiKey,
    };
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    final uri = Uri.parse(_base).replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      if (data['articles'] == null) return [];
      return (data['articles'] as List)
          .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch news: ${res.statusCode}');
    }
  }

  Future<List<NewsModel>> fetchBreakingHeadlines(
      {String country = 'us', int limit = 6}) async {
    final list = await fetchTopHeadlines(country: country, pageSize: limit);
    return list;
  }
}
