import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/cart_provider.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// Event-driven cart. CartProvider is its repository (data + disk), so there
/// is only one cart in the app.
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartProvider _repository;

  CartBloc(this._repository) : super(_read(_repository)) {
    on<AddProductEvent>((event, emit) {
      _repository.add(event.product);
      emit(_read(_repository));
    });
    on<RemoveProductEvent>((event, emit) {
      _repository.remove(event.productId);
      emit(_read(_repository));
    });
    on<ChangeQuantityEvent>((event, emit) {
      _repository.changeQuantity(event.productId, event.difference);
      emit(_read(_repository));
    });
    on<ClearCartEvent>((event, emit) {
      _repository.clear();
      emit(_read(_repository));
    });
    on<CartSyncedEvent>((event, emit) => emit(_read(_repository)));

    _repository.addListener(_onRepositoryChanged);
  }

  static CartState _read(CartProvider cart) => CartState(
    items: cart.items,
    totalPrice: cart.total,
    count: cart.quantity,
  );

  void _onRepositoryChanged() => add(const CartSyncedEvent());

  @override
  Future<void> close() {
    _repository.removeListener(_onRepositoryChanged);
    return super.close();
  }
}
