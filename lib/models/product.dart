class Product {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final String mood;
  final List<String> tags;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.mood,
    required this.tags,
  });

  /// shortcut: fixed demo rate so API (USD) and local (₸) prices add up in
  /// one cart; use a live exchange-rate API for real prices.
  static const kztPerUsd = 500;

  static const _moodByCategory = {
    'electronics': 'Study',
    'jewelery': 'Cozy',
    "men's clothing": 'Travel',
    "women's clothing": 'Travel',
  };

  /// LAB 9: null-safe fallbacks; `as num` accepts both 109 and 109.95.
  factory Product.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map<String, dynamic>? ?? const {};
    final category = json['category'] as String? ?? 'other';
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      price: ((json['price'] as num?) ?? 0).toDouble() * kztPerUsd,
      rating: ((rating['rate'] as num?) ?? 0).toDouble(),
      reviewCount: (rating['count'] as num?)?.toInt() ?? 0,
      category: category,
      mood: _moodByCategory[category] ?? 'Cozy',
      tags: [category],
    );
  }

  /// shortcut: the API gives one photo per product, so the carousel shows it
  /// 3 times; switch to a real image list when the backend has one.
  List<String> get gallery => List.filled(3, imageUrl);

  String get heroTag => 'product_image_$id';
}
