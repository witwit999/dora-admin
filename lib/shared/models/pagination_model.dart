/// Page information from paginated API responses
class PageInfo {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  const PageInfo({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasMore => page < totalPages;
}

/// Paginated products response from API
class PaginatedProducts {
  final List<dynamic> items;
  final PageInfo page;

  const PaginatedProducts({
    required this.items,
    required this.page,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    return PaginatedProducts(
      items: json['items'] as List<dynamic>,
      page: PageInfo.fromJson(json['page'] as Map<String, dynamic>),
    );
  }
}

/// Paginated notifications response from API
class PaginatedNotifications {
  final List<dynamic> items;
  final PageInfo page;

  const PaginatedNotifications({
    required this.items,
    required this.page,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    return PaginatedNotifications(
      items: json['items'] as List<dynamic>,
      page: PageInfo.fromJson(json['page'] as Map<String, dynamic>),
    );
  }
}
