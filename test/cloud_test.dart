import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:final_project/models/product.dart';
import 'package:final_project/screens/cloud_screen.dart';
import 'package:final_project/screens/product_detail_screen.dart';
import 'package:final_project/services/product_api.dart';
import 'package:final_project/state/shop_state.dart';

const _json = {
  'id': 7,
  'title': 'White Gold Ring',
  'price': 10, // int on purpose
  'description': 'Classic ring',
  'category': 'jewelery',
  'image': 'https://fakestoreapi.com/img/ring.jpg',
  'rating': {'rate': 3, 'count': 400},
};

ProductApi apiReturning(int status, [Object body = const [_json]]) =>
    ProductApi(
      client: MockClient((_) async => http.Response(jsonEncode(body), status)),
    );

Future<String> errorOf(ProductApi api) async {
  try {
    await api.fetchProducts();
    return 'no error';
  } on ApiException catch (e) {
    return e.message;
  }
}

void main() {
  group('Product.fromJson', () {
    test('int price and rating become doubles', () {
      final p = Product.fromJson(_json);
      expect(p.id, 7);
      expect(p.price, 10.0 * Product.kztPerUsd);
      expect(p.rating, 3.0);
      expect(p.reviewCount, 400);
      expect(p.imageUrl, endsWith('ring.jpg'));
      expect(p.heroTag, 'product_image_7');
    });

    test('missing fields fall back instead of crashing', () {
      final p = Product.fromJson({'id': 1});
      expect(p.title, 'Untitled product');
      expect(p.price, 0);
      expect(p.rating, 0);
      expect(p.reviewCount, 0);
      expect(p.gallery, hasLength(3));
    });
  });

  group('ProductApi status codes', () {
    test('200 parses the list', () async {
      final products = await apiReturning(200).fetchProducts();
      expect(products.single.title, 'White Gold Ring');
    });

    test('404, 500, offline, timeout and bad JSON', () async {
      expect(await errorOf(apiReturning(404)), contains('404'));
      expect(await errorOf(apiReturning(500)), contains('500'));
      expect(
        await errorOf(apiReturning(200, {'not': 'a list'})),
        contains('invalid'),
      );
      expect(
        await errorOf(
          ProductApi(
            client: MockClient((_) async => throw http.ClientException('x')),
          ),
        ),
        'No internet connection.',
      );
      expect(
        await errorOf(
          ProductApi(
            timeout: const Duration(milliseconds: 10),
            client: MockClient((_) async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              return http.Response('[]', 200);
            }),
          ),
        ),
        contains('timeout'),
      );
    });
  });

  testWidgets('loading → error → Retry Connection → list', (tester) async {
    var online = false;
    final api = ProductApi(
      client: MockClient((_) async {
        if (!online) throw http.ClientException('offline');
        return http.Response(jsonEncode([_json]), 200);
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CloudScreen(api: api, onOpenProduct: (_) {}),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('No internet connection.'), findsOneWidget);

    online = true; // airplane mode off
    await tester.tap(find.text('Retry Connection'));
    await tester.pumpAndSettle();
    expect(find.text('White Gold Ring'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('detail carousel counts pages and share shows deep link', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(
          product: Product.fromJson(_json),
          shop: ShopState(),
        ),
      ),
    );
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
    expect(find.text('narxoz://store/product/7'), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
  });
}
