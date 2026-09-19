import 'package:flutter/material.dart';


// void checkBalance({
//  required String name,
//  required double balance,
// }) => print('$name balance: $balance');
//
// double deposit({
//  required double currentBalance,
//  double? amount,
// }){
//  double a = amount ?? 0.0;
//  if(a < 0.0){
//   print('Error: Deposit amount cannot be negative');
//   return currentBalance;
//  }
//  double updateBalance =currentBalance + a ;
//  print('Current Balance: $currentBalance');
//  print('Amount: $a');
//  print('updatedBalance: $updateBalance');
//
//  return updateBalance;
// }
//
// double withdraw({
// required String name,
// required double currentBalance ,
// double? amount,
// int? pinCode}){
//  if((pinCode ?? 0000) != 1234){
//   print("Error Pincode is incorrect");
//   return currentBalance;
//  }
//
//  double a = amount ?? 0.0;
//  if(a < 0.0){
//   print('Deposit amount cannot be negative');
//   return currentBalance;
//  }
//  if(a > currentBalance){
//   print('Error Insufficient funds');
//   return currentBalance;
//  }
//  double updateBalance = currentBalance - a;
//  print('Withdrawn: $a');
//  print('updateBalance: $updateBalance');
//  return updateBalance;
//
// }


class Book {
 String title;
 String author;
 double price;
 bool isBorrowed;

 Book({
  required this.title,
  required this.author,
  required this.price,
  this.isBorrowed = false
});




}

void main() {













 // checkBalance(name: "Ernur", balance: 10000000.0);
 // double d = deposit(currentBalance: 1009,amount: 670);
 // print(d);
 // double balance = withdraw(name: "Ernur",currentBalance: 500.0,amount: 100.0,pinCode: 1234);
 // print(balance);














 
 }
