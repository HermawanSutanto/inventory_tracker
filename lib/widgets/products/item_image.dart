import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemImage extends StatelessWidget {
  final String imageUrl;

  const ItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Memeriksa apakah URL adalah jalur aset lokal
    final bool isAsset = imageUrl.startsWith('assets/');

    return Container(
      width: 60, // Peningkatan ukuran
      height: 60,
      decoration: BoxDecoration(
        color: Colors.yellow[600],
        borderRadius: BorderRadius.circular(10), // Sedikit lebih bulat
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child:
            isAsset
                ? Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildErrorWidget(context), // Fallback untuk aset
                )
                : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          _buildErrorWidget(context), // Fallback untuk jaringan
                ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
      ),
    );
  }
}
