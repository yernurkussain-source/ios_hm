import '../models/product.dart';

const moods = ['All', 'Study', 'Gym', 'Travel', 'Cozy'];

const catalog = <Product>[
  Product(
    id: 101,
    title: 'Focus Headphones',
    description:
        'Comfortable wireless headphones for studying and deep work. '
        'Enjoy clear sound and a lightweight design all day long.',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=900',
    price: 24990,
    rating: 4.8,
    reviewCount: 250,
    category: 'Electronics',
    mood: 'Study',
    tags: ['Audio', 'Wireless', 'Study'],
  ),
  Product(
    id: 102,
    title: 'Fitness Smartwatch',
    description:
        'Track your workouts and daily movement with a modern '
        'smartwatch built for an active lifestyle.',
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=900',
    price: 45990,
    rating: 4.7,
    reviewCount: 184,
    category: 'Gadgets',
    mood: 'Gym',
    tags: ['Fitness', 'Wearable', 'Gym'],
  ),
  Product(
    id: 103,
    title: 'City Sneakers',
    description:
        'Lightweight, soft sneakers for daily walks and '
        'comfortable adventures around the city.',
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
    price: 32990,
    rating: 4.9,
    reviewCount: 412,
    category: 'Fashion',
    mood: 'Travel',
    tags: ['Shoes', 'Comfort', 'Travel'],
  ),
  Product(
    id: 104,
    title: 'Instant Camera',
    description:
        'Capture your best memories wherever you go with '
        'this portable and easy-to-use camera.',
    imageUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=900',
    price: 69990,
    rating: 4.6,
    reviewCount: 97,
    category: 'Photography',
    mood: 'Travel',
    tags: ['Camera', 'Creative', 'Travel'],
  ),
  Product(
    id: 105,
    title: 'Cozy Desk Lamp',
    description:
        'A warm desk lamp that creates a peaceful atmosphere '
        'for reading, relaxing and evening study.',
    imageUrl:
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=900',
    price: 18990,
    rating: 4.7,
    reviewCount: 136,
    category: 'Home',
    mood: 'Cozy',
    tags: ['Lighting', 'Room', 'Cozy'],
  ),
  Product(
    id: 106,
    title: 'Everyday Backpack',
    description:
        'A roomy, water-resistant backpack with a padded laptop pocket '
        'for campus days and weekend trips.',
    imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=900',
    price: 27990,
    rating: 4.8,
    reviewCount: 203,
    category: 'Fashion',
    mood: 'Travel',
    tags: ['Bag', 'Laptop', 'Travel'],
  ),
];

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
