import 'package:equatable/equatable.dart';

class CartState extends Equatable {
  /// Product id → quantity.
  final Map<int, int> items;
  final double totalPrice;
  final int count;

  const CartState({
    required this.items,
    required this.totalPrice,
    required this.count,
  });

  @override
  List<Object?> get props => [items, totalPrice, count];
}
