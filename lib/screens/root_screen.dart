import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/coin.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'coins_screen.dart';
import 'favorites_screen.dart';
import 'feed_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final shop = ShopState();
  int selectedTab = 0;

  static const _titles = ['Discover', 'Catalog', 'Favorites', 'Profile'];
  static const _catalogTab = 1;
  bool catalogGrid = false;

  @override
  void dispose() {
    shop.dispose();
    super.dispose();
  }

  void selectTab(int index) {
    if (index != selectedTab) HapticFeedback.selectionClick();
    setState(() => selectedTab = index);
  }

  Widget _tab(int index, Widget child) =>
      HeroMode(enabled: index == selectedTab, child: child);

  void openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product, shop: shop),
      ),
    );
  }

  void openCoins() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => CoinsScreen(shop: shop)),
    );
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => CartScreen(shop: shop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: shop,
      builder: (context, _) => Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(_titles[selectedTab]),
          actions: [
            // LAB 8: List ↔ Grid toggle, only on the Catalog tab.
            if (selectedTab == _catalogTab)
              IconButton(
                tooltip: catalogGrid ? 'List view' : 'Grid view',
                onPressed: () => setState(() => catalogGrid = !catalogGrid),
                icon: Icon(
                  catalogGrid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
              ),
            CoinPill(
              coins: shop.coins,

              hasNews: !shop.checkedInToday || shop.claimableMissions > 0,
              onTap: openCoins,
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Shopping cart',
              onPressed: openCart,
              icon: Badge(
                isLabelVisible: shop.cartQuantity > 0,
                label: Text('${shop.cartQuantity}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: IndexedStack(
          index: selectedTab,
          children: [
            _tab(0, FeedScreen(shop: shop, onOpenProduct: openProduct)),
            _tab(
              _catalogTab,
              CatalogScreen(grid: catalogGrid, onOpenProduct: openProduct),
            ),
            _tab(
              2,
              FavoritesScreen(
                shop: shop,
                onOpenProduct: openProduct,
                onBrowse: () => selectTab(0),
              ),
            ),
            _tab(
              3,
              ProfileScreen(
                shop: shop,
                onOpenFavorites: () => selectTab(2),
                onOpenCart: openCart,
                onOpenCoins: openCoins,
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Glass(
            child: BottomNavigationBar(
              currentIndex: selectedTab,
              onTap: selectTab,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: _ActivePill(icon: Icons.explore),
                  label: 'Feed',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: _ActivePill(icon: Icons.grid_view_rounded),
                  label: 'Catalog',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: shop.favorites.isNotEmpty,
                    label: Text('${shop.favorites.length}'),
                    child: const Icon(Icons.favorite_border),
                  ),
                  activeIcon: const _ActivePill(icon: Icons.favorite),
                  label: 'Favorites',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: _ActivePill(icon: Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  final IconData icon;

  const _ActivePill({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
