import 'dart:convert';

import 'show.dart';

enum WatchStatus {
  planToWatch('Plan to Watch'),
  watching('Watching'),
  completed('Completed'),
  dropped('Dropped');

  const WatchStatus(this.label);

  final String label;

  static WatchStatus fromName(String? name) {
    return WatchStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => WatchStatus.planToWatch,
    );
  }
}

/// A show saved in the user's personal collection.
///
/// Saved shows use Hive as their source of truth, so the collection keeps
/// working without an internet connection.
class SavedShow {
  const SavedShow({
    required this.id,
    required this.name,
    required this.genres,
    required this.summary,
    required this.notes,
    required this.watchStatus,
    required this.savedAt,
    this.type,
    this.language,
    this.status,
    this.rating,
    this.premiered,
    this.ended,
    this.runtime,
    this.imageMedium,
    this.imageOriginal,
    this.network,
    this.officialSite,
  });

  final int id;
  final String name;
  final String? type;
  final String? language;
  final String? status;
  final List<String> genres;
  final double? rating;
  final String? premiered;
  final String? ended;
  final int? runtime;
  final String summary;
  final String? imageMedium;
  final String? imageOriginal;
  final String? network;
  final String? officialSite;
  final String notes;
  final WatchStatus watchStatus;
  final DateTime savedAt;

  String get year => premiered != null && premiered!.length >= 4
      ? premiered!.substring(0, 4)
      : 'TBA';

  String get ratingText => rating == null ? 'N/A' : rating!.toStringAsFixed(1);

  factory SavedShow.fromShow(
    Show show, {
    WatchStatus watchStatus = WatchStatus.planToWatch,
    String notes = '',
  }) {
    return SavedShow(
      id: show.id,
      name: show.name,
      type: show.type,
      language: show.language,
      status: show.status,
      genres: show.genres,
      rating: show.rating,
      premiered: show.premiered,
      ended: show.ended,
      runtime: show.runtime,
      summary: show.summary,
      imageMedium: show.imageMedium,
      imageOriginal: show.imageOriginal,
      network: show.network,
      officialSite: show.officialSite,
      notes: notes,
      watchStatus: watchStatus,
      savedAt: DateTime.now(),
    );
  }

  Show toShow() {
    return Show(
      id: id,
      name: name,
      type: type,
      language: language,
      status: status,
      genres: genres,
      rating: rating,
      premiered: premiered,
      ended: ended,
      runtime: runtime,
      summary: summary,
      imageMedium: imageMedium,
      imageOriginal: imageOriginal,
      network: network,
      officialSite: officialSite,
    );
  }

  SavedShow copyWith({String? notes, WatchStatus? watchStatus}) {
    return SavedShow(
      id: id,
      name: name,
      type: type,
      language: language,
      status: status,
      genres: genres,
      rating: rating,
      premiered: premiered,
      ended: ended,
      runtime: runtime,
      summary: summary,
      imageMedium: imageMedium,
      imageOriginal: imageOriginal,
      network: network,
      officialSite: officialSite,
      notes: notes ?? this.notes,
      watchStatus: watchStatus ?? this.watchStatus,
      savedAt: savedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'language': language,
      'status': status,
      'genres': genres,
      'rating': rating,
      'premiered': premiered,
      'ended': ended,
      'runtime': runtime,
      'summary': summary,
      'imageMedium': imageMedium,
      'imageOriginal': imageOriginal,
      'network': network,
      'officialSite': officialSite,
      'notes': notes,
      'watchStatus': watchStatus.name,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedShow.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'];
    return SavedShow(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Untitled',
      type: json['type'] as String?,
      language: json['language'] as String?,
      status: json['status'] as String?,
      genres: rawGenres is List
          ? rawGenres.whereType<String>().toList()
          : const [],
      rating: (json['rating'] as num?)?.toDouble(),
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      summary: json['summary'] as String? ?? '',
      imageMedium: json['imageMedium'] as String?,
      imageOriginal: json['imageOriginal'] as String?,
      network: json['network'] as String?,
      officialSite: json['officialSite'] as String?,
      notes: json['notes'] as String? ?? '',
      watchStatus: WatchStatus.fromName(json['watchStatus'] as String?),
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static SavedShow? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return SavedShow.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Corrupt Hive entries are ignored instead of breaking the collection.
    }
    return null;
  }
}
