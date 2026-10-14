import 'package:flutter/material.dart';

enum ServiceCategory { cleaning, gardening }

class ServiceItem {
  final String id;
  final String title;
  final ServiceCategory category;
  final String shortDescription;
  final String fullDescription;
  final double basePrice;
  final String duration;
  final double rating;
  final int reviewCount;
  final List<String> inclusions;
  final List<String> exclusions;
  final IconData icon;
  final String tag;
  final bool isPopular;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.fullDescription,
    required this.basePrice,
    required this.duration,
    required this.rating,
    required this.reviewCount,
    required this.inclusions,
    required this.exclusions,
    required this.icon,
    this.tag = '',
    this.isPopular = false,
  });

  String get formattedPrice => '₹${basePrice.toStringAsFixed(0)}';

  String get categoryName {
    switch (category) {
      case ServiceCategory.cleaning:
        return 'Home Cleaning';
      case ServiceCategory.gardening:
        return 'Gardening Care';
    }
  }
}
