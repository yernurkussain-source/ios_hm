import 'package:flutter/material.dart';


// void processOrder({
//   required int orderId,
//   required double itemprice,
//   String? promocode,
//   double? deliveryFee,
// }){
//   double price = itemprice;
//   if(promocode == "SAVE10"){
//     price = price * 0.9;
//   }
//
//   double delivery = deliveryFee ?? 500.0;
//   if(delivery<500){
//     delivery=500;
//   }
//   double finalTotal = price + delivery;
//
//
//
//   print('OrderId: $orderId');
//   print('ItemPrice: $itemprice');
//   print('Promocode: $promocode');
//   print('Delivery: $delivery ');
//   print('FinalTotal: $finalTotal');
// }


void checkBalance({
 required String name,
 required double balance,
}) => print('$name balance: $balance');

double deposit({
 required double currentBalance,
 double? amount,
}){
 double a = amount ?? 0.0;
 if(a < 0.0){
  print('Error: Deposit amount cannot be negative');
  return currentBalance;
 }
 double updateBalance =currentBalance + a ;
 print('Current Balance: $currentBalance');
 print('Amount: $a');
 print('updatedBalance: $updateBalance');
 
 return updateBalance;
}

double withdraw({
required String name,
required double currentBalance ,
double? amount,
int? pinCode}){
 if((pinCode ?? 0000) != 1234){
  print("Error Pincode is incorrect");
  return currentBalance;
 }

 double a = amount ?? 0.0;
 if(a < 0.0){
  print('Deposit amount cannot be negative');
  return currentBalance;
 }
 if(a > currentBalance){
  print('Error Insufficient funds');
  return currentBalance;
 }
 double updateBalance = currentBalance - a;
 print('Withdrawn: $a');
 print('updateBalance: $updateBalance');
 return updateBalance;

}

void main() {
 checkBalance(name: "Ernur", balance: 10000000.0);
 double d = deposit(currentBalance: 1009,amount: 670);
 print(d);
 double balance = withdraw(name: "Ernur",currentBalance: 500.0,amount: 100.0,pinCode: 1234);
 print(balance);




  // void total = processOrder(
  //   orderId: 1,
  //   itemprice: 10000.0,
  //   promocode: 'SAVE10',
  //   deliveryFee: 100
  // );


  //Task 1
//   for(int i = 1 ; i <= 10 ; i ++){
//     for(int j =1; j<=10 ; j++){
//       print("$i * $j = ${i*j}");
//     }
//     print("");
//     print("");
//
//   }
//
  //Task 2
  //   int day = 31;
  //   int month = 15;
  //   int year = 2025;
  //
  //   int maxDay;
  //
  //
  //   if (month == 2) {
  //     if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) {
  //       maxDay = 29;
  //     } else {
  //       maxDay = 28;
  //     }
  //   } else if (month == 4 || month == 6 || month == 9 || month == 11) {
  //     maxDay = 30;
  //   } else {
  //     maxDay = 31;
  //   }
  //
  //   if (day > maxDay || month >12 ) {
  //     print("invalid date");
  //   } else {
  //     day++;
  //
  //     if (day > maxDay) {
  //       day = 1;
  //       month++;
  //
  //       if (month > 12) {
  //         month = 1;
  //         year++;
  //       }
  //     }
  //
  //     print("$day.$month.$year");
  //   }
  //
  //
  // //Task 3
  //   String s = 'flutter mobile development';
  //   int c = 0;
  //   for(int i = 0; i < s.length; i++){
  //     if(s[i]=='a' || s[i]=='e' || s[i]=='i' || s[i]=='o' || s[i]=='u'){
  //       c++;
  //     }
  //   }
  //   print('Count: $c');
//
//   //Task 4
//   List<int> numbers = [14,88,3 ,42,99,12,67];
//   int first = numbers[0];
//   int last = numbers[numbers.length-1];
//   for(int i = 1; i<numbers.length ;i++){
//     if(numbers[i] < first){
//       first = numbers[i];
//     }
//   }
//   for(int i=numbers.length-2;i>0;i--){
//     if(numbers[i] > last){
//       last = numbers[i];
//     }
//   }
//   print('max: $last , min: $first');
//
//   //Task 5
//   int num = 11;
//   int count = 0;
//   for(int i=2;i<=num/2;i++){
//     if(num%i == 0){
//       count++;
//     }
//   }
//   if(count == 2){
//     print('$num -> prime number');
//   }else{
//     print('$num -> not prime number');
//  }
//
 }
