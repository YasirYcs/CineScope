import 'package:flutter/material.dart';

import '../../core/utils/text_utils.dart';
import '../../data/models/app_exception.dart';
import '../../data/models/saved_show.dart';
import '../../data/models/show.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/show_repository.dart';
import '../widgets/collection_dialogs.dart';
import '../widgets/rating_badge.dart';
import '../widgets/show_poster.dart';
import '../widgets/watch_status_chip.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.initialShow,
    required this.showRepository,
    required this.collectionRepository,
  });

  final Show initialShow;
  final ShowRepository showRepository;
  final CollectionRepository collectionRepository;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Show _show;
  bool _loadingDetails = true;
  String? _detailsError;

  @override
  void initState() {
    super.initState();
    _show = widget.initialShow;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    if (!_loadingDetails) {
      setState(() {
        _loadingDetails = true;
        _detailsError = null;
      });
    }

    try {
      final detailedShow = await widget.showRepository.getShow(_show.id);
      if (!mounted) return;
      setState(() {
        _show = detailedShow;
        _detailsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _detailsError = error is AppException
            ? error.message
            : 'Could not refresh this show right now.';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingDetails = false);
      }
    }
  }

  Future<void> _saveOrEdit(SavedShow? saved) async {
    final isNew = saved == null;
    final result = await showSavedShowForm(
      context,
      title: isNew ? 'Add to Collection' : 'Edit Collection',
      initialNotes: saved?.notes ?? '',
      initialWatchStatus: saved?.watchStatus ?? WatchStatus.planToWatch,
    );

    if (!mounted || result == null) return;

    if (isNew) {
      await widget.collectionRepository.add(
        _show,
        watchStatus: result.watchStatus,
        notes: result.notes,
      );
    } else {
      await widget.collectionRepository.update(
        saved.copyWith(notes: result.notes, watchStatus: result.watchStatus),
      );
    }

    if (!mounted) return;
    _showSnack(
      isNew ? 'Added to your collection.' : 'Collection entry updated.',
    );
  }

  Future<void> _deleteSaved(SavedShow saved) async {
    final confirmed = await showDeleteConfirmation(
      context,
      showName: saved.name,
    );

    if (!mounted || !confirmed) return;

    await widget.collectionRepository.delete(saved.id);
    if (!mounted) return;
    _showSnack('Removed from your collection.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          if (_loadingDetails)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;

                final poster = Hero(
                  tag: 'show-poster-${_show.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ShowPoster(url: _show.posterUrl),
                    ),
                  ),
                );

                final info = _buildInfo(context);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_detailsError != null) ...[
                      _InlineError(
                        message: _detailsError!,
                        onRetry: _loadDetails,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 290, child: poster),
                          const SizedBox(width: 36),
                          Expanded(child: info),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Center(child: SizedBox(width: 220, child: poster)),
                          const SizedBox(height: 24),
                          info,
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _show.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RatingBadge(rating: _show.rating),
            if ((_show.status ?? '').isNotEmpty)
              _Pill(
                icon: Icons.radio_button_checked_rounded,
                text: _show.status!,
              ),
            _Pill(icon: Icons.calendar_today_rounded, text: _show.year),
          ],
        ),
        if (_show.genres.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _show.genres
                .map(
                  (genre) => Chip(
                    label: Text(genre),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 20),
        _buildCollectionSection(context),
        const Divider(height: 34),
        Text(
          'Overview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _show.plainSummary.isEmpty
              ? 'No summary available for this show yet.'
              : _show.plainSummary,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 30,
          runSpacing: 16,
          children: [
            _MetaItem(
              icon: Icons.tv_rounded,
              label: 'Network',
              value: _show.network ?? 'Unknown',
            ),
            _MetaItem(
              icon: Icons.language_rounded,
              label: 'Language',
              value: _show.language ?? 'Unknown',
            ),
            _MetaItem(
              icon: Icons.category_outlined,
              label: 'Type',
              value: _show.type ?? 'Unknown',
            ),
            _MetaItem(
              icon: Icons.schedule_rounded,
              label: 'Runtime',
              value: _show.runtime == null ? 'Unknown' : '${_show.runtime} min',
            ),
            _MetaItem(
              icon: Icons.event_available_rounded,
              label: 'Premiered',
              value: _show.premiereDate,
            ),
            if (_show.ended != null)
              _MetaItem(
                icon: Icons.event_busy_rounded,
                label: 'Ended',
                value: formatDate(_show.ended),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionSection(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: widget.collectionRepository,
      builder: (context, _) {
        final saved = widget.collectionRepository.findById(_show.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => _saveOrEdit(saved),
                  icon: Icon(
                    saved == null
                        ? Icons.bookmark_add_outlined
                        : Icons.edit_rounded,
                    size: 18,
                  ),
                  label: Text(
                    saved == null ? 'Add to Collection' : 'Edit Collection',
                  ),
                ),
                if (saved != null)
                  OutlinedButton.icon(
                    onPressed: () => _deleteSaved(saved),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove'),
                  ),
              ],
            ),
            if (saved != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        WatchStatusChip(status: saved.watchStatus),
                        const Spacer(),
                        Text(
                          'Saved ${formatDate(saved.savedAt.toIso8601String())}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    if (saved.notes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        saved.notes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white60),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
