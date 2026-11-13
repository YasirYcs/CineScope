import 'package:flutter/material.dart';

import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/show_repository.dart';
import 'collection_screen.dart';
import 'explore_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.showRepository,
    required this.collectionRepository,
  });

  final ShowRepository showRepository;
  final CollectionRepository collectionRepository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExploreScreen(
        showRepository: widget.showRepository,
        collectionRepository: widget.collectionRepository,
      ),
      CollectionScreen(
        showRepository: widget.showRepository,
        collectionRepository: widget.collectionRepository,
        onExplore: () => setState(() => _selectedIndex = 0),
      ),
    ];
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final body = IndexedStack(index: _selectedIndex, children: _pages);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectTab,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: const Color(0xFF0D0F16),
                    indicatorColor: primary.withValues(alpha: 0.16),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Icon(Icons.movie_filter_rounded, color: primary),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: Text('Explore'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bookmark_border_rounded),
                        selectedIcon: Icon(Icons.bookmark_rounded),
                        label: Text('Collection'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'My Collection',
              ),
            ],
          ),
        );
      },
    );
  }
}
