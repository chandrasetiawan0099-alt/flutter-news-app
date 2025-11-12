import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel article;
  final String heroTag;
  const NewsDetailScreen({Key? key, required this.article, required this.heroTag}) : super(key: key);

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('EEEE, d MMM yyyy • HH:mm').format(dt);
  }

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No URL available')));
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open URL')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Article'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Hero(
            tag: heroTag,
            child: article.urlToImage != null
                ? Image.network(article.urlToImage!, width: double.infinity, height: 300, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 300, color: Colors.grey.shade200))
                : Container(width: double.infinity, height: 300, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article.title ?? '(No title)', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(children: [
                if ((article.author ?? '').isNotEmpty) Text(article.author!, style: TextStyle(color: Colors.grey.shade700)),
                if ((article.author ?? '').isNotEmpty) const SizedBox(width: 8),
                Text(article.sourceName ?? '', style: TextStyle(color: Colors.grey.shade700)),
                const Spacer(),
                Text(_formatDate(article.publishedAt), style: TextStyle(color: Colors.grey.shade600)),
              ]),
              const SizedBox(height: 14),
              if ((article.description ?? '').isNotEmpty)
                Text(article.description!, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 12),
              if ((article.content ?? '').isNotEmpty) Text(article.content!, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 20),
              Row(children: [
                ElevatedButton.icon(onPressed: () => _openUrl(context, article.url), icon: const Icon(Icons.open_in_new), label: const Text('Open Original')),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share), label: const Text('Share')),
              ]),
              const SizedBox(height: 36),
            ]),
          )
        ]),
      ),
    );
  }
}