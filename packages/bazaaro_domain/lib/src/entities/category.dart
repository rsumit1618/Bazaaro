class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.order,
    required this.isActive,
    this.parentId,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final int order;
  final bool isActive;
  final String? parentId;
  final String? imageUrl;
}
