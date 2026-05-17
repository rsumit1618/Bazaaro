enum UserRole {
  superAdmin,
  admin,
  seller,
  inventoryManager,
  orderManager,
  supportAgent,
  marketingManager,
  contentManager,
  customer,
}

enum UserStatus { active, blocked, deleted }

enum ProductStatus { draft, pending, active, inactive, rejected, outOfStock }

enum PaymentStatus { pending, paid, failed, refunded }

enum PaymentProvider { razorpay, stripe, cashfree, cod }

enum OrderStatus {
  placed,
  confirmed,
  packed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

enum ReviewStatus { pending, approved, rejected }

enum ReturnStatus { requested, approved, rejected, picked, refunded }

enum CouponType { percentage, flat }

enum BannerPlacement { homeTop, homeMiddle, productDetail, checkout }
