import 'package:flutter/material.dart';
import '../models/portfolio_photo.dart';

class PortfolioGrid extends StatelessWidget {
  final List<PortfolioPhoto> photos;
  final void Function(String photoUrl)? onPhotoTap;

  const PortfolioGrid({
    super.key,
    required this.photos,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No portfolio photos yet.')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          onTap: () => onPhotoTap?.call(photo.photoUrl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              photo.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        );
      },
    );
  }
}
