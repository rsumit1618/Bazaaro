class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.variantId,
  });

  final String id;
  final String productId;
  final String? variantId;
  final int quantity;
  final num price;

  num get lineTotal => quantity * price;
}
