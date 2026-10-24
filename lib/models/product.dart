class Product {
  final int id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double rating;
  final int reviews;
  final String category;
  final String mood;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.mood,
    required this.tags,
  });

  String get heroTag => 'product-image-$id';
}
