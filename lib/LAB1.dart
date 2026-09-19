void processOrder({
  required int orderId,
  required double itemprice,
  String? promocode,
  double? deliveryFee,
}){
  double price = itemprice;
  if(promocode == "SAVE10"){
    price = price * 0.9;
  }

  double delivery = deliveryFee ?? 500.0;
  if(delivery<500){
    delivery=500;
  }
  double finalTotal = price + delivery;



  print('OrderId: $orderId');
  print('ItemPrice: $itemprice');
  print('Promocode: $promocode');
  print('Delivery: $delivery ');
  print('FinalTotal: $finalTotal');
}

void main(){
  void total = processOrder(
    orderId: 1,
    itemprice: 10000.0,
    promocode: 'SAVE10',
    deliveryFee: 100
  );
}