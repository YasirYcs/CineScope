import 'package:flutter/material.dart';

import '../../data/models/show.dart';
import 'rating_badge.dart';
import 'show_poster.dart';

class ShowCard extends StatelessWidget {
  const ShowCard({
    super.key,
    required this.show,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
  });

  final Show show;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'show-poster-${show.id}',
                    child: ShowPoster(url: show.thumbnailUrl),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.68),
                        ],
                        stops: const [0.55, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      onPressed: onToggleSaved,
                      tooltip: isSaved
                          ? 'Remove from collection'
                          : 'Add to collection',
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.55),
                        foregroundColor: isSaved ? primary : Colors.white,
                        minimumSize: const Size(34, 34),
                        padding: EdgeInsets.zero,
                      ),
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_add_outlined,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 8,
                    child: RatingBadge(rating: show.rating),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${show.year}  /  ${show.genreText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
