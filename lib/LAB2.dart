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

void main(){
  String name = "Ernur";
  double balance = 120000;
  checkBalance(name: name, balance: balance);
  balance = deposit(currentBalance: balance,amount: 670);
  balance = withdraw(name: name,currentBalance: balance,amount: 100.0,pinCode: 1234);
  print(balance);
}