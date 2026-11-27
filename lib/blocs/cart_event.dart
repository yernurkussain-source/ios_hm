import 'package:equatable/equatable.dart';

import '../models/product.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddProductEvent extends CartEvent {
  final Product product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product.id];
}

class RemoveProductEvent extends CartEvent {
  final int productId;

  const RemoveProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ChangeQuantityEvent extends CartEvent {
  final int productId;
  final int difference;

  const ChangeQuantityEvent(this.productId, this.difference);

  @override
  List<Object?> get props => [productId, difference];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

/// The cart changed outside the bloc (product page, checkout).
class CartSyncedEvent extends CartEvent {
  const CartSyncedEvent();
}
