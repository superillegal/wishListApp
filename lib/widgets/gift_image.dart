import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GiftThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const GiftThumbnail({super.key, required this.imageUrl, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final placeholderIcon = Icon(
      Icons.card_giftcard,
      size: size * 0.6,
      color: Theme.of(context).colorScheme.primary,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: _buildImage(placeholderIcon),
      ),
    );
  }

  Widget _buildImage(Widget placeholderIcon) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return placeholderIcon;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.broken_image_outlined,
        size: size * 0.6,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class GiftHeaderImage extends StatelessWidget {
  final String? imageUrl;
  final String title;

  const GiftHeaderImage({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          color: Colors.grey.shade200,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _buildImage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _EmptyImage(title: title);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => _EmptyImage(title: title),
    );
  }
}

class _EmptyImage extends StatelessWidget {
  final String title;
  const _EmptyImage({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
