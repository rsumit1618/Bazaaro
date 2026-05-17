import 'package:bazaaro_core/bazaaro_core.dart';

class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.images,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final List<String> images;
  final ReviewStatus status;
  final DateTime createdAt;
}
