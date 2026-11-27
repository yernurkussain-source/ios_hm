import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/cart_bloc.dart';
import '../blocs/cart_state.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/coin.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'cloud_screen.dart';
import 'coins_screen.dart';
import 'favorites_screen.dart';
import 'feed_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';

class RootScreen extends StatefulWidget {
  static const catalogTab = 1;

  final int initialTab;

  const RootScreen({super.key, this.initialTab = 0});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final ShopState shop;
  late int selectedTab = widget.initialTab;

  static const _titles = [
    'Discover',
    'Catalog',
    'Cloud Store',
    'Favorites',
    'Profile',
  ];
  static const _cloudTab = 2;

  bool cloudOpened = false;
  bool catalogGrid = false;

  @override
  void initState() {
    super.initState();
    shop = ShopState(
      cart: context.read<CartProvider>(),
      prefs: context.read<SharedPreferences>(),
    );
  }

  @override
  void dispose() {
    shop.dispose();
    super.dispose();
  }

  void selectTab(int index) {
    if (index != selectedTab) HapticFeedback.selectionClick();
    setState(() {
      selectedTab = index;
      if (index == _cloudTab) cloudOpened = true;
    });
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
            if (selectedTab == RootScreen.catalogTab)
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
              icon: BlocBuilder<CartBloc, CartState>(
                builder: (_, cart) => Badge(
                  isLabelVisible: cart.count > 0,
                  label: Text('${cart.count}'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
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
              RootScreen.catalogTab,
              CatalogScreen(grid: catalogGrid, onOpenProduct: openProduct),
            ),
            _tab(
              _cloudTab,
              cloudOpened
                  ? CloudScreen(onOpenProduct: openProduct)
                  : const SizedBox.shrink(),
            ),
            _tab(
              3,
              FavoritesScreen(
                shop: shop,
                onOpenProduct: openProduct,
                onBrowse: () => selectTab(0),
              ),
            ),
            _tab(
              4,
              ProfileScreen(
                shop: shop,
                onOpenFavorites: () => selectTab(3),
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
                const BottomNavigationBarItem(
                  icon: Icon(Icons.cloud_outlined),
                  activeIcon: _ActivePill(icon: Icons.cloud_rounded),
                  label: 'Cloud',
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      decoration: BoxDecoration(
        color: context.palette.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: context.palette.canvas),
    );
  }
}
