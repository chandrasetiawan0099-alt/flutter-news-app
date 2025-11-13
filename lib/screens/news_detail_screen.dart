import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../models/news_model.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsModel article;
  final String heroTag;
  const NewsDetailScreen(
      {Key? key, required this.article, required this.heroTag})
      : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _showShareLink = false;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('EEEE, d MMM yyyy • HH:mm').format(dt);
  }

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No URL available')));
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cannot open URL')));
    }
  }

  Future<void> _shareViaSystem(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No link to share')));
      return;
    }
    try {
      await Share.share(url);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unable to share link')));
    }
  }

  Future<void> _copyToClipboard(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No link to copy')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      appBar: AppBar(title: const Text('Article'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Hero(
            tag: widget.heroTag,
            child: article.urlToImage != null
                ? Image.network(article.urlToImage!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 300, color: Colors.grey.shade200))
                : Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article.title ?? '(No title)',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(children: [
                if ((article.author ?? '').isNotEmpty)
                  Text(article.author!,
                      style: TextStyle(color: Colors.grey.shade700)),
                if ((article.author ?? '').isNotEmpty) const SizedBox(width: 8),
                Text(article.sourceName ?? '',
                    style: TextStyle(color: Colors.grey.shade700)),
                const Spacer(),
                Text(_formatDate(article.publishedAt),
                    style: TextStyle(color: Colors.grey.shade600)),
              ]),
              const SizedBox(height: 14),
              if ((article.description ?? '').isNotEmpty)
                Text(article.description!,
                    style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 12),
              if ((article.content ?? '').isNotEmpty)
                Text(article.content!,
                    style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 20),

              // Share link panel (hidden by default)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showShareLink
                    ? Container(
                        key: const ValueKey('share_panel'),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                article.url ?? '',
                                maxLines: 2,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _copyToClipboard(article.url),
                              icon: const Icon(Icons.copy),
                              label: const Text('Share Link'),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () =>
                                  setState(() => _showShareLink = false),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Row(children: [
                ElevatedButton.icon(
                    onPressed: () => _openUrl(context, article.url),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Original')),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // toggle visibility of share link panel
                    if ((article.url ?? '').isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No link to share')));
                      return;
                    }
                    setState(() => _showShareLink = !_showShareLink);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                const SizedBox(width: 8),
                // keep system share as an extra option
                IconButton(
                  tooltip: 'Share using system',
                  onPressed: () => _shareViaSystem(article.url),
                  icon: const Icon(Icons.more_horiz),
                ),
              ]),
              const SizedBox(height: 36),
            ]),
          )
        ]),
      ),
    );
  }
}
