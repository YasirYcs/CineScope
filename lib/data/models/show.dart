import '../../core/utils/text_utils.dart';

class Show {
  const Show({
    required this.id,
    required this.name,
    this.type,
    this.language,
    this.status,
    this.genres = const [],
    this.rating,
    this.premiered,
    this.ended,
    this.runtime,
    this.summary = '',
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

  String? get thumbnailUrl => imageMedium ?? imageOriginal;
  String? get posterUrl => imageOriginal ?? imageMedium;

  String get plainSummary => stripHtml(summary);
  String get year => yearFromDate(premiered);
  String get premiereDate => formatDate(premiered);
  String get ratingText => rating == null ? 'N/A' : rating!.toStringAsFixed(1);
  String get genreText =>
      genres.isEmpty ? 'Uncategorized' : genres.take(2).join(' / ');

  factory Show.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    final ratingJson = json['rating'];
    final imageJson = json['image'];
    final networkJson = json['network'];
    final rawGenres = json['genres'];

    return Show(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: rawName is String && rawName.trim().isNotEmpty
          ? rawName.trim()
          : 'Untitled',
      type: json['type'] as String?,
      language: json['language'] as String?,
      status: json['status'] as String?,
      genres: rawGenres is List
          ? rawGenres.whereType<String>().toList()
          : const [],
      rating: ratingJson is Map
          ? (ratingJson['average'] as num?)?.toDouble()
          : null,
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      summary: json['summary'] as String? ?? '',
      imageMedium: imageJson is Map ? imageJson['medium'] as String? : null,
      imageOriginal: imageJson is Map ? imageJson['original'] as String? : null,
      network: networkJson is Map ? networkJson['name'] as String? : null,
      officialSite: json['officialSite'] as String?,
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
      'rating': {'average': rating},
      'premiered': premiered,
      'ended': ended,
      'runtime': runtime,
      'summary': summary,
      'image': {'medium': imageMedium, 'original': imageOriginal},
      'network': {'name': network},
      'officialSite': officialSite,
    };
  }
}
