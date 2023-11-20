import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String isbn; // Add the ISBN field if it's part of your data
  final String title;
  final String authors;
  final double averageRating;
  final int numPages;
  final int ratingsCount;
  final int textReviewsCount;
  final int publication_date;
  final String bookImage;

  Book({
    required this.isbn,
    required this.title,
    required this.authors,
    required this.averageRating,
    required this.numPages,
    required this.ratingsCount,
    required this.textReviewsCount,
    required this.publication_date,
    required this.bookImage,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Book(
      isbn: data['isbn'] ?? '', // Add the ISBN field if it's part of your data
      title: data['title'] ?? '',
      authors: data['authors'] ?? '',
      averageRating: (data['average_rating'] ?? 0.0).toDouble(),
      numPages: data['num_of_pages'] ?? 0,
      ratingsCount: data['ratings_count'] ?? 0,
      textReviewsCount: data['text_reviews_count'] ?? 0,
      publication_date: data['publication_date'] ?? [],
      bookImage: data['book_image'] ??
          '', // Add the actual field name from your Firestore document
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn, // Add the ISBN field if it's part of your data
      'title': title,
      'authors': authors,
      'average_rating': averageRating,
      'num_of_pages': numPages,
      'ratings_count': ratingsCount,
      'text_reviews_count': textReviewsCount,
      'publication_date': publication_date,
      'book_image':
          bookImage, // Add the actual field name to your Firestore document
    };
  }
}

class DatabaseService {
  final String userEmail;

  DatabaseService({required this.userEmail});

  final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('books');
  final CollectionReference userBooksCollection =
      FirebaseFirestore.instance.collection('user-book');

  Future<void> addUserBook(Book book) async {
    await userBooksCollection
        .doc(userEmail)
        .collection('books-to-read')
        .doc(book.isbn)
        .set(book.toMap());
  }

  Future<void> addBook(Book book) async {
    await booksCollection.doc(book.isbn).set(book.toMap());
  }

  Future<void> markBookAsRead(Book book) async {
    await userBooksCollection
        .doc(userEmail)
        .collection('books-read')
        .doc(book.isbn)
        .set(book.toMap());
  }

  Stream<List<Book>> getBooksToRead() {
    return userBooksCollection
        .doc(userEmail)
        .collection('books-to-read')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getBooksRead() {
    return userBooksCollection
        .doc(userEmail)
        .collection('books-read')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getAllBooks() {
    return booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }
}
