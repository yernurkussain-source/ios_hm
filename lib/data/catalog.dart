import '../models/product.dart';

const moods = ['All', 'Study', 'Gym', 'Travel', 'Cozy'];

const catalog = <Product>[
  Product(
    id: 1,
    name: 'Focus Headphones',
    description:
        'Comfortable wireless headphones for studying and deep work. '
        'Enjoy clear sound and a lightweight design all day long.',
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=900',
    price: 24990,
    rating: 4.8,
    reviews: 250,
    category: 'Electronics',
    mood: 'Study',
    tags: ['Audio', 'Wireless', 'Study'],
  ),
  Product(
    id: 2,
    name: 'Fitness Smartwatch',
    description:
        'Track your workouts and daily movement with a modern '
        'smartwatch built for an active lifestyle.',
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=900',
    price: 45990,
    rating: 4.7,
    reviews: 184,
    category: 'Gadgets',
    mood: 'Gym',
    tags: ['Fitness', 'Wearable', 'Gym'],
  ),
  Product(
    id: 3,
    name: 'City Sneakers',
    description:
        'Lightweight, soft sneakers for daily walks and '
        'comfortable adventures around the city.',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
    price: 32990,
    rating: 4.9,
    reviews: 412,
    category: 'Fashion',
    mood: 'Travel',
    tags: ['Shoes', 'Comfort', 'Travel'],
  ),
  Product(
    id: 4,
    name: 'Instant Camera',
    description:
        'Capture your best memories wherever you go with '
        'this portable and easy-to-use camera.',
    image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=900',
    price: 69990,
    rating: 4.6,
    reviews: 97,
    category: 'Photography',
    mood: 'Travel',
    tags: ['Camera', 'Creative', 'Travel'],
  ),
  Product(
    id: 5,
    name: 'Cozy Desk Lamp',
    description:
        'A warm desk lamp that creates a peaceful atmosphere '
        'for reading, relaxing and evening study.',
    image: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=900',
    price: 18990,
    rating: 4.7,
    reviews: 136,
    category: 'Home',
    mood: 'Cozy',
    tags: ['Lighting', 'Room', 'Cozy'],
  ),
];

/// Items created at runtime by pull-to-refresh (LAB 8), so cart and
/// favorites can still find them by id.
final generatedProducts = <Product>[];

List<Product> get allProducts => [...catalog, ...generatedProducts];

Product productById(int id) => allProducts.firstWhere((p) => p.id == id);

String money(double value) {
  final digits = value.toStringAsFixed(0);
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
  return '$grouped ₸';
}
