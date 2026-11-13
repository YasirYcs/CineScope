import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowPoster extends StatelessWidget {
  const ShowPoster({super.key, required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    if (imageUrl.isEmpty) return const _PosterPlaceholder();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (context, url) => const _PosterPlaceholder(),
      errorWidget: (context, url, error) => const _PosterPlaceholder(),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF171A24),
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.white24,
          size: 34,
        ),
      ),
    );
  }
}
