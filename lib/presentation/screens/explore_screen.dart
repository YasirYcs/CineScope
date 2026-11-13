import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/app_exception.dart';
import '../../data/models/show.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/show_repository.dart';
import '../widgets/show_card.dart';
import '../widgets/state_views.dart';
import 'details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.showRepository,
    required this.collectionRepository,
  });

  final ShowRepository showRepository;
  final CollectionRepository collectionRepository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<Show> _shows = [];
  List<Show> _searchResults = [];
  int _page = 0;
  int _searchRequest = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _fromCache = false;
  bool _loadingSearch = false;
  bool _searchFromCache = false;
  String _query = '';
  String? _error;
  String? _searchError;

  bool get _isSearchMode => _query.isNotEmpty;

  bool get _hasVisibleResults =>
      _isSearchMode ? _searchResults.isNotEmpty : _shows.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      _loadMore();
    }
  }

  Future<void> _loadInitial({bool refresh = false}) async {
    if (_isSearchMode) {
      await _runSearch(_query);
      return;
    }

    final hadContent = _shows.isNotEmpty;
    setState(() {
      if (!refresh) _loading = true;
      _error = null;
      _loadingMore = false;
      _hasMore = true;
    });

    try {
      final page = await widget.showRepository.getShows(0);
      if (!mounted) return;
      setState(() {
        _shows = page.shows;
        _page = 0;
        _fromCache = page.fromCache;
        _hasMore = page.hasMore;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!hadContent) _error = _messageFor(error);
      });
      if (hadContent) {
        _showSnack('Refresh failed. Showing the shows already loaded.');
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _isSearchMode) return;

    setState(() => _loadingMore = true);
    final nextPage = _page + 1;

    try {
      final page = await widget.showRepository.getShows(nextPage);
      if (!mounted) return;

      final existingIds = _shows.map((show) => show.id).toSet();
      setState(() {
        _shows = [
          ..._shows,
          ...page.shows.where((show) => !existingIds.contains(show.id)),
        ];
        _page = nextPage;
        _fromCache = page.fromCache;
        _hasMore = page.hasMore && page.shows.isNotEmpty;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _hasMore = false;
      });
      _showSnack('Could not load more shows. ${_messageFor(error)}');
    }
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      _searchRequest++;
      setState(() {
        _query = '';
        _searchResults = [];
        _loadingSearch = false;
        _searchError = null;
        _searchFromCache = false;
      });
      return;
    }

    setState(() {
      _query = query;
      _loadingSearch = true;
      _searchError = null;
    });

    _debounce = Timer(AppConstants.searchDebounce, () => _runSearch(query));
  }

  void _onSubmitted(String value) {
    final query = value.trim();
    _debounce?.cancel();
    if (query.isNotEmpty) {
      _runSearch(query);
    }
  }

  Future<void> _runSearch(String query, {bool showLoading = true}) async {
    final requestId = ++_searchRequest;

    if (showLoading) {
      setState(() {
        _loadingSearch = true;
        _searchError = null;
      });
    }

    try {
      final page = await widget.showRepository.searchShows(query);
      if (!mounted || requestId != _searchRequest || _query != query) return;

      setState(() {
        _searchResults = page.shows;
        _searchFromCache = page.fromCache;
        _loadingSearch = false;
        _searchError = null;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequest) return;

      setState(() {
        _loadingSearch = false;
        _searchError = _messageFor(error);
        _searchResults = [];
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _onQueryChanged('');
  }

  Future<void> _refresh() async {
    if (_isSearchMode) {
      await _runSearch(_query, showLoading: false);
      return;
    }
    await _loadInitial(refresh: true);
  }

  void _openDetails(Show show) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetailsScreen(
          initialShow: show,
          showRepository: widget.showRepository,
          collectionRepository: widget.collectionRepository,
        ),
      ),
    );
  }

  Future<void> _toggleSaved(Show show) async {
    final wasSaved = widget.collectionRepository.isSaved(show.id);
    await widget.collectionRepository.toggle(show);
    if (!mounted) return;
    _showSnack(
      wasSaved
          ? '"${show.name}" removed from your collection.'
          : '"${show.name}" added to your collection.',
    );
  }

  String _messageFor(Object error) {
    return error is AppException
        ? error.message
        : 'Something went wrong. Please try again.';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Cine',
                style: TextStyle(color: primary),
              ),
              const TextSpan(text: 'Scope'),
            ],
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.collectionRepository,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onQueryChanged,
                  onSubmitted: _onSubmitted,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search TV shows...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              if ((_isSearchMode ? _searchFromCache : _fromCache) &&
                  _hasVisibleResults)
                OfflineBanner(onRetry: () => _refresh()),
              Expanded(child: _buildContent(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: constraints.maxWidth >= 1100 ? 210 : 185,
          childAspectRatio: 0.60,
          crossAxisSpacing: 14,
          mainAxisSpacing: 18,
        );

        return _isSearchMode
            ? _buildSearchResults(context, gridDelegate)
            : _buildBrowse(context, gridDelegate);
      },
    );
  }

  Widget _buildBrowse(BuildContext context, SliverGridDelegate gridDelegate) {
    if (_loading && _shows.isEmpty) {
      return const SkeletonGrid();
    }

    if (_error != null && _shows.isEmpty) {
      return _refreshableState(
        StateView(
          icon: Icons.cloud_off_rounded,
          title: 'Unable to load shows',
          message: _error!,
          actionLabel: 'Try again',
          onAction: () => _loadInitial(),
        ),
      );
    }

    if (_shows.isEmpty) {
      return _refreshableState(
        const StateView(
          icon: Icons.live_tv_outlined,
          title: 'No shows found',
          message: 'TVMaze did not return any shows. Pull down to try again.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildFeaturedShows(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverGrid(
              delegate: _showDelegate(_shows),
              gridDelegate: gridDelegate,
            ),
          ),
          SliverToBoxAdapter(child: _buildFooter(context)),
        ],
      ),
    );
  }

  Widget _buildFeaturedShows() {
    final featuredShows = [..._shows]
      ..sort((a, b) => (b.rating ?? -1).compareTo(a.rating ?? -1));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Featured',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Top rated on TVMaze',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 276,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: featuredShows.length.clamp(0, 5),
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final show = featuredShows[index];
                  return SizedBox(
                    width: 158,
                    child: ShowCard(
                      show: show,
                      isSaved: widget.collectionRepository.isSaved(show.id),
                      onTap: () => _openDetails(show),
                      onToggleSaved: () => _toggleSaved(show),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SliverGridDelegate gridDelegate,
  ) {
    final theme = Theme.of(context);

    if (_loadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchError != null) {
      return _refreshableState(
        StateView(
          icon: Icons.search_off_rounded,
          title: 'Search failed',
          message: _searchError!,
          actionLabel: 'Try again',
          onAction: () => _runSearch(_query),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _refreshableState(
        StateView(
          icon: Icons.manage_search_rounded,
          title: 'No matches found',
          message: 'Nothing matched "$_query". Try a different title.',
          actionLabel: 'Clear search',
          actionIcon: Icons.close_rounded,
          onAction: _clearSearch,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${_searchResults.length} result'
                '${_searchResults.length == 1 ? '' : 's'} for "$_query"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverGrid(
              delegate: _showDelegate(_searchResults),
              gridDelegate: gridDelegate,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _refreshableState(Widget child) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
      ),
    );
  }

  SliverChildBuilderDelegate _showDelegate(List<Show> shows) {
    return SliverChildBuilderDelegate((context, index) {
      final show = shows[index];
      return ShowCard(
        show: show,
        isSaved: widget.collectionRepository.isSaved(show.id),
        onTap: () => _openDetails(show),
        onToggleSaved: () => _toggleSaved(show),
      );
    }, childCount: shows.length);
  }

  Widget _buildFooter(BuildContext context) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.only(top: 4, bottom: 28),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!_hasMore && _shows.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 28),
        child: Center(
          child: Text(
            'You have reached the end',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white38),
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}
