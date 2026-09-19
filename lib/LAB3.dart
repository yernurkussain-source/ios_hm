// class Book{
//   String title;
//   String author;
//   double price;
//   bool isBorrowed;
//
//   Book({
//     required this.title,
//     required this.author,
//     required this.price,
//     this.isBorrowed = false
//
// });
// }
// class Library{
//   List<Book> _books = [];
//
//   void addBook(Book book){
//     _books.add(book);
//   }
//
//   List<Book> getAvailableBooks(){
//     return _books.where((book) => book.isBorrowed == false).toList();
//   }
//
//   double getTotalValue(){
//     return _books.fold(0.0 ,(total,book) => total + book.price);
//   }
// }

abstract class MediaItem {
  String id;
  String title;
  double price;
  MediaItem(this.id, this.title, this.price);
  String getDetails();
}

mixin Downloadable {
  void download(String title) {
    print("Downloading $title...");
  }
}

class Audiobook extends MediaItem with Downloadable {
  double durationHours;
  String narrator;
  Audiobook(
      String id,
      String title,
      double price,
      this.durationHours,
      this.narrator,
      ) : super(id, title, price);

  @override
  String getDetails() {
    return "Audiobook: $title, Price: \$$price, "
        "Duration: $durationHours hours, Narrator: $narrator";
  }
}


class EBook extends MediaItem with Downloadable {
  double fileSizeMB;
  String author;

  EBook(
      String id,
      String title,
      double price,
      this.fileSizeMB,
      this.author,
      ) : super(id, title, price);

  @override
  String getDetails() {
    return "EBook: $title, Price: \$$price, "
        "Size: $fileSizeMB MB, Author: $author";
  }
}

class ShoppingCart {
  final List<MediaItem> _items = [];
  void addItem(MediaItem item) {
    _items.add(item);
  }

  double calculateTotalWithTax({double taxRate = 0.12}) {
    double total = _items.fold(
      0.0,
          (sum, item) => sum + item.price,
    );
    return total + (total * taxRate);
  }

  List<MediaItem> filterByMaxPrice(double maxPrice) {
    return _items
        .where((item) => item.price <= maxPrice)
        .toList();
  }
  void printReceipt() {
    print("Receipt");
    for (var item in _items) {
      print(item.getDetails());
      if (item is Downloadable) {
        (item as Downloadable).download(item.title);
      }
    }
    print("Total with tax: \$${calculateTotalWithTax()}");
  }
}
void main() {
  Audiobook book1 = Audiobook(
    "A1",
    "Harry Potter",
    15.0,
    8.5,
    "Jim Dale",
  );
  EBook book2 = EBook(
    "E1",
    "Clean Code",
    10.0,
    5.2,
    "Robert Martin",
  );
  ShoppingCart cart = ShoppingCart();
  cart.addItem(book1);
  cart.addItem(book2);
  cart.printReceipt();
  print("\nItems under \$12:");
  List<MediaItem> cheapItems = cart.filterByMaxPrice(12.0);
  for (var item in cheapItems) {
    print(item.getDetails());
  }


  // Library library = new Library();
  // library.addBook(Book(title:"Harry Potter", author: "Random Acts of Crazy", price: 6.99));
  // library.addBook(Book(title: "Random Acts of Fantasy ", author: "Julia Kent", price: 3.99 ));
  // library.addBook(Book(title: "Random Russian A1 ", author: "Matthew Aldrich және Dmitry Pikhur", price: 4.99));
  // for(Book book in library.getAvailableBooks()){
  //   print("Book title:${book.title} Book author: ${book.author} Book price: ${book.price}");
  // }
  // print(library.getTotalValue());

}