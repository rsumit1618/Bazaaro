class MarketingBanner {
  const MarketingBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.redirectType,
    required this.placement,
    required this.isActive,
    this.redirectId,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String redirectType;
  final String placement;
  final bool isActive;
  final String? redirectId;
}
