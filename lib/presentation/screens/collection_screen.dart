import 'package:flutter/material.dart';

import '../../data/models/saved_show.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/show_repository.dart';
import '../widgets/collection_dialogs.dart';
import '../widgets/rating_badge.dart';
import '../widgets/show_poster.dart';
import '../widgets/state_views.dart';
import '../widgets/watch_status_chip.dart';
import 'details_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.showRepository,
    required this.collectionRepository,
    this.onExplore,
  });

  final ShowRepository showRepository;
  final CollectionRepository collectionRepository;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Collection')),
      body: ListenableBuilder(
        listenable: collectionRepository,
        builder: (context, _) {
          final savedShows = collectionRepository.getAll();

          if (savedShows.isEmpty) {
            return StateView(
              icon: Icons.bookmark_border_rounded,
              title: 'Your collection is empty',
              message:
                  'Save shows from Explore to track your watch status and '
                  'keep personal notes.',
              actionLabel: onExplore == null ? null : 'Explore shows',
              actionIcon: Icons.explore_rounded,
              onAction: onExplore,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemCount: savedShows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final savedShow = savedShows[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: _SavedShowCard(
                    item: savedShow,
                    onOpen: () => _openDetails(context, savedShow),
                    onEdit: () => _edit(context, savedShow),
                    onDelete: () => _delete(context, savedShow),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, SavedShow savedShow) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DetailsScreen(
          initialShow: savedShow.toShow(),
          showRepository: showRepository,
          collectionRepository: collectionRepository,
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, SavedShow savedShow) async {
    final result = await showSavedShowForm(
      context,
      title: 'Edit "${savedShow.name}"',
      initialNotes: savedShow.notes,
      initialWatchStatus: savedShow.watchStatus,
    );

    if (result == null || !context.mounted) return;

    await collectionRepository.update(
      savedShow.copyWith(notes: result.notes, watchStatus: result.watchStatus),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Collection entry updated.')),
      );
  }

  Future<void> _delete(BuildContext context, SavedShow savedShow) async {
    final confirmed = await showDeleteConfirmation(
      context,
      showName: savedShow.name,
    );

    if (!confirmed || !context.mounted) return;

    await collectionRepository.delete(savedShow.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"${savedShow.name}" was removed.')),
      );
  }
}

enum _SavedShowAction { edit, delete }

class _SavedShowCard extends StatelessWidget {
  const _SavedShowCard({
    required this.item,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedShow item;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 78,
                  height: 117,
                  child: ShowPoster(
                    url: item.imageMedium ?? item.imageOriginal,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          height: 30,
                          child: PopupMenuButton<_SavedShowAction>(
                            tooltip: 'More actions',
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            onSelected: (action) {
                              switch (action) {
                                case _SavedShowAction.edit:
                                  onEdit();
                                case _SavedShowAction.delete:
                                  onDelete();
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _SavedShowAction.edit,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 10),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: _SavedShowAction.delete,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        WatchStatusChip(status: item.watchStatus),
                        RatingBadge(rating: item.rating),
                        Text(
                          item.year,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.notes.isEmpty
                          ? 'No notes yet - use Edit to add notes.'
                          : item.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: item.notes.isEmpty
                            ? Colors.white38
                            : Colors.white60,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
