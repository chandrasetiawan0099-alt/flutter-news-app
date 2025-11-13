import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../models/news_model.dart';
import '../services/news_service.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _service = NewsService();
  late Future<List<NewsModel>> _future;
  late Future<List<NewsModel>> _breakingFuture;

  String _selectedCategory = 'general';
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // update UI (to show/hide clear button)
      setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final categoryParam =
        _selectedCategory == 'general' ? null : _selectedCategory;
    _future = _service.fetchTopHeadlines(
        country: 'us', pageSize: 40, category: categoryParam, q: _searchQuery);
    _breakingFuture = _service.fetchBreakingHeadlines(country: 'us', limit: 6);
  }

  Future<void> _refresh() async {
    setState(_loadData);
    try {
      await Future.wait([_future, _breakingFuture]);
    } catch (_) {}
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('d MMM • HH:mm').format(dt);
  }

  Widget _shimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 180,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 12),
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 150, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          const SizedBox(width: 8),
          const Text('GLOBAL NEWS',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const Spacer(),
          SizedBox(
            width: 340,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                _searchQuery = v.trim().isEmpty ? null : v.trim();
                setState(() => _loadData());
              },
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = null;
                              setState(() => _loadData());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              _searchQuery =
                                  _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim();
                              setState(() => _loadData());
                            },
                          ),
                        ],
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline)),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Subscribe')),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    final categories = NewsService.getCategories();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final key = cat['key']!;
          final label = cat['label']!;
          final selected = key == _selectedCategory;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (v) {
              if (!v) return;
              // clear search when switching categories (optional). Remove next line to keep search across categories.
              // _searchController.clear(); _searchQuery = null;
              setState(() {
                _selectedCategory = key;
                _loadData();
              });
            },
            selectedColor: Colors.red.shade600,
            backgroundColor: Colors.grey.shade100,
            labelStyle:
                TextStyle(color: selected ? Colors.white : Colors.black87),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }

  Widget _buildBreakingTicker() {
    return FutureBuilder<List<NewsModel>>(
      future: _breakingFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 44);
        } else if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return const SizedBox(height: 44);
        }
        final items = snap.data!;
        return Container(
          color: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('BREAKING',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final a = items[idx];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => NewsDetailScreen(
                                    article: a,
                                    heroTag: a.url ?? 'breaking-$idx'))),
                        child: Row(
                          children: [
                            Text(a.title ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            if (idx != items.length - 1)
                              const Text(' • ',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatured(NewsModel a, String heroTag) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NewsDetailScreen(article: a, heroTag: heroTag))),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              if (a.urlToImage != null)
                Image.network(
                  a.urlToImage!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade300, height: 220),
                )
              else
                Container(height: 220, color: Colors.grey.shade300),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent
                    ]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title ?? '(No title)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(a.sourceName ?? 'Unknown',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text(_formatDate(a.publishedAt),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(NewsModel a, int index) {
    final heroTag = a.url ?? 'news-$index';
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NewsDetailScreen(article: a, heroTag: heroTag))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: a.urlToImage != null
                    ? Image.network(
                        a.urlToImage!,
                        width: 110,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 78,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image)),
                      )
                    : Container(
                        width: 110,
                        height: 78,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 78,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title ?? '(No title)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Row(
                      children: [
                        Text(a.sourceName ?? 'Unknown',
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 12)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text(_formatDate(a.publishedAt),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTrending(List<NewsModel> list) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.trending_up, color: Colors.red),
          SizedBox(width: 8),
          Text('Trending Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
        ]),
        const SizedBox(height: 12),
        ...List.generate(list.length, (i) {
          final a = list[i];
          return Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${i + 1}',
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(a.title ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 8),
          ]);
        })
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: SafeArea(child: _buildHeader(context))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<NewsModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                  itemBuilder: (_, __) => _shimmerItem(), itemCount: 4);
            } else if (snapshot.hasError) {
              return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text('Error: ${snapshot.error}'))
                  ]);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('No articles found'))
                  ]);
            }

            final articles = snapshot.data!;
            return ListView(
              children: [
                const SizedBox(height: 8),
                _buildCategoryBar(),
                const SizedBox(height: 8),
                _buildBreakingTicker(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildFeatured(articles[0],
                                    articles[0].url ?? 'featured')),
                            const SizedBox(width: 12),
                            Column(children: [
                              SizedBox(
                                width: 320,
                                child: Column(
                                  children: [
                                    for (var i = 1;
                                        i <
                                            (articles.length >= 4
                                                ? 4
                                                : articles.length);
                                        i++)
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child:
                                              _buildListItem(articles[i], i)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              FutureBuilder<List<NewsModel>>(
                                  future: _breakingFuture,
                                  builder: (c, s) {
                                    if (!s.hasData) return const SizedBox();
                                    return _buildTrending(s.data!);
                                  })
                            ])
                          ],
                        )
                      : Column(
                          children: [
                            _buildFeatured(
                                articles[0], articles[0].url ?? 'featured'),
                            const SizedBox(height: 12),
                            for (var i = 1; i < articles.length; i++)
                              _buildListItem(articles[i], i),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
