
void main() {
//Task 1
  for (int i = 1; i <= 10; i ++) {
    for (int j = 1; j <= 10; j++) {
      print("$i * $j = ${i * j}");
    }
    print("");
    print("");
  }

//Task 2
  int day = 31;
  int month = 15;
  int year = 2025;

  int maxDay;


  if (month == 2) {
    if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) {
      maxDay = 29;
    } else {
      maxDay = 28;
    }
  } else if (month == 4 || month == 6 || month == 9 || month == 11) {
    maxDay = 30;
  } else {
    maxDay = 31;
  }

  if (day > maxDay || month > 12) {
    print("invalid date");
  } else {
    day++;

    if (day > maxDay) {
      day = 1;
      month++;

      if (month > 12) {
        month = 1;
        year++;
      }
    }

    print("$day.$month.$year");
  }


// //Task 3
  String s = 'flutter mobile development';
  int c = 0;
  for (int i = 0; i < s.length; i++) {
    if (s[i] == 'a' || s[i] == 'e' || s[i] == 'i' || s[i] == 'o' ||
        s[i] == 'u') {
      c++;
    }
  }
  print('Count: $c');

//   //Task 4
  List<int> numbers = [14, 88, 3, 42, 99, 12, 67];
  int first = numbers[0];
  int last = numbers[numbers.length - 1];
  for (int i = 1; i < numbers.length; i++) {
    if (numbers[i] < first) {
      first = numbers[i];
    }
  }
  for (int i = numbers.length - 2; i > 0; i--) {
    if (numbers[i] > last) {
      last = numbers[i];
    }
  }
  print('max: $last , min: $first');

//   //Task 5
  int num = 11;
  int count = 0;
  for (int i = 2; i <= num / 2; i++) {
    if (num % i == 0) {
      count++;
    }
  }
  if (count == 2) {
    print('$num -> prime number');
  } else {
    print('$num -> not prime number');
  }
}