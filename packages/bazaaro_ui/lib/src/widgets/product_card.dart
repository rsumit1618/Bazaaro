import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/bazaaro_theme.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final appTheme = BazaaroTheme.app;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        scale: _hovered ? 1.025 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: appTheme.cardBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: appTheme.border.withValues(alpha: 0.7)),
            boxShadow: _hovered ? appTheme.shadow : appTheme.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final available =
                      constraints.maxHeight.isFinite &&
                          constraints.maxHeight > 0
                      ? constraints.maxHeight
                      : 326;
                  final imageHeight = (available * .50)
                      .clamp(124, 190)
                      .toDouble();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                              scale: _hovered ? 1.08 : 1,
                              child: CachedNetworkImage(
                                imageUrl: product.images.isEmpty
                                    ? ''
                                    : product.images.first,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => ColoredBox(
                                  color: appTheme.softSurface,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: appTheme.brandAccent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    '${product.discountPercent}% OFF',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: appTheme.brandInk,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: Ink(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [appTheme.primary, appTheme.pink],
                                    ),
                                    boxShadow: appTheme.softShadow,
                                  ),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: product.isInStock
                                        ? widget.onAddToCart
                                        : null,
                                    child: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      height: 1.12,
                                      color: appTheme.brandInk,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product.brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: appTheme.muted),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: appTheme.orange,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      '${product.ratingAvg.toStringAsFixed(1)} (${product.ratingCount})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      '${BazaaroBrand.currency} ${product.price}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: appTheme.brandInk,
                                          ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      '${BazaaroBrand.currency} ${product.mrp}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: appTheme.muted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
