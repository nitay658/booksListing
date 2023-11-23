import 'package:books_app/book_database.dart';
import 'package:flutter/material.dart';

class AddBookToDataBasePage extends StatefulWidget {
  final String userEmail;

  const AddBookToDataBasePage({Key? key, required this.userEmail})
      : super(key: key);

  @override
  _AddBookToDataBasePageState createState() => _AddBookToDataBasePageState();
}

class _AddBookToDataBasePageState extends State<AddBookToDataBasePage> {
  late String userEmail;
  late List<Book> books;
  late DatabaseService databaseService;

  // Controllers for the form fields
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _averageRatingController =
      TextEditingController();
  final TextEditingController _numPagesController = TextEditingController();
  final TextEditingController _ratingsCountController = TextEditingController();
  final TextEditingController _textReviewsCountController =
      TextEditingController();
  final TextEditingController _publicationDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    books = [];
    databaseService = DatabaseService(userEmail: userEmail);

    // Fetch books once when the widget is created
    databaseService.getAllBooks().listen((List<Book> data) {
      setState(() {
        books = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add New Book',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(labelText: 'ISBN'),
                    ),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    TextFormField(
                      controller: _imageController,
                      decoration:
                          const InputDecoration(labelText: 'Book Image URL'),
                    ),
                    TextFormField(
                      controller: _averageRatingController,
                      decoration:
                          const InputDecoration(labelText: 'Average Rating'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _numPagesController,
                      decoration:
                          const InputDecoration(labelText: 'Number of Pages'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _ratingsCountController,
                      decoration:
                          const InputDecoration(labelText: 'Ratings Count'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _textReviewsCountController,
                      decoration: const InputDecoration(
                          labelText: 'Text Reviews Count'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _publicationDateController,
                      decoration:
                          const InputDecoration(labelText: 'Publication Date'),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Create a new Book object from the form data
                        Book newBook = Book(
                          isbn: _isbnController.text,
                          title: _titleController.text,
                          authors: _authorController.text,
                          averageRating:
                              double.parse(_averageRatingController.text),
                          numPages: int.parse(_numPagesController.text),
                          ratingsCount: int.parse(_ratingsCountController.text),
                          textReviewsCount:
                              int.parse(_textReviewsCountController.text),
                          publication_date:
                              int.parse(_publicationDateController.text),
                          bookImage: _imageController.text,
                        );

                        // Add the new book to the database
                        databaseService.addBook(newBook);

                        // Clear the form fields
                        _isbnController.clear();
                        _titleController.clear();
                        _authorController.clear();
                        _imageController.clear();
                        _averageRatingController.clear();
                        _numPagesController.clear();
                        _ratingsCountController.clear();
                        _textReviewsCountController.clear();
                        _publicationDateController.clear();
                      },
                      child: const Text('Add Book'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
