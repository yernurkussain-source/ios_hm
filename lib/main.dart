import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 5 - Product Preview',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ProductPreviewScreen(),
    );
  }
}

class ProductPreviewScreen extends StatefulWidget {
  const ProductPreviewScreen({super.key});

  @override
  State<ProductPreviewScreen> createState() => _ProductPreviewScreenState();
}

class _ProductPreviewScreenState extends State<ProductPreviewScreen> {
  bool _bookmarked = false;
  bool _favorite = false;

  static const _categories = [
    'Electronics',
    'Audio',
    'Wireless',
    'Noise Cancelling',
    'Bluetooth 5.3',
    'Best Seller',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------- BODY ----------
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              // Үлкен экран: сол жақта сурет, оң жақта мәлімет
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(child: _buildCover()),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildDetails(),
                    ),
                  ),
                ],
              );
            }

            // Шағын экран: бәрі бір бағанда, бірге скролл болады
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCover(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDetails(),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // ---------- STICKY BOTTOM BAR ----------
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ================= COVER: Stack =================
  Widget _buildCover() {
    return Stack(
      children: [
        // 1) Негізгі сурет (placeholder)
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.headphones, size: 120, color: Colors.white70),
            ),
          ),
        ),

        // 2) Артқа қайту батырмасы (сол жақ жоғары)
        Positioned(
          top: 12,
          left: 12,
          child: _circleButton(
            icon: Icons.arrow_back,
            onTap: () {},
          ),
        ),

        // 3) Bookmark badge (оң жақ жоғары)
        Positioned(
          top: 12,
          right: 12,
          child: _circleButton(
            icon: _bookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _bookmarked ? Colors.amber.shade800 : Colors.black87,
            onTap: () => setState(() => _bookmarked = !_bookmarked),
          ),
        ),

        // 4) Жеңілдік badge (сол жақ төмен)
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '-25%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  // ================= DETAILS =================
  Widget _buildDetails() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Row: атауы (Expanded) + бағасы ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Wireless Noise-Cancelling Headphones Pro Max',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$149',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // --- Рейтинг: Wrap, тар экранда келесі қатарға түседі ---
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Icon(
                  i < 4 ? Icons.star : Icons.star_half,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            Text('4.5', style: textTheme.titleSmall),
            Text(
              '(1 284 reviews)',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Category badges: Wrap ---
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map(_buildBadge).toList(),
        ),
        const SizedBox(height: 20),

        Text('Description', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Premium over-ear headphones with active noise cancellation, '
              '40-hour battery life, fast charging (10 min = 5 hours), '
              'soft memory-foam ear cushions and crystal-clear sound. '
              'Supports multipoint connection and a built-in microphone '
              'for calls.',
          style: textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBadge(String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ================= BOTTOM BAR =================
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Қосымша кішкентай батырма (тұрақты өлшем)
              IconButton.outlined(
                onPressed: () => setState(() => _favorite = !_favorite),
                icon: Icon(
                  _favorite ? Icons.favorite : Icons.favorite_border,
                  color: _favorite ? Colors.red : null,
                ),
              ),
              const SizedBox(width: 12),

              // Қалған БАРЛЫҚ орынды Expanded алады -> толық ені
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart ✓')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text(
                    'Add to Cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
