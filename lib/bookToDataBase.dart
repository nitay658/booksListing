import 'package:flutter/material.dart';
import 'book_database.dart';

class AddBookToDataBasePage extends StatefulWidget {
  final String userEmail;

  const AddBookToDataBasePage({Key? key, required this.userEmail})
      : super(key: key);

  @override
  State<AddBookToDataBasePage> createState() => _AddBookToDataBasePageState();
}

class _AddBookToDataBasePageState extends State<AddBookToDataBasePage> {
  late String userEmail;
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
    databaseService = DatabaseService(userEmail: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF21BFBD),
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
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: Container(
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
                      const SizedBox(height: 16.0),
                      buildTextField(_isbnController, 'ISBN'),
                      buildTextField(_titleController, 'Title'),
                      buildTextField(_authorController, 'Author'),
                      buildTextField(_imageController, 'Book Image URL'),
                      buildNumericTextField(_averageRatingController, 'Average Rating'),
                      buildNumericTextField(_numPagesController, 'Number of Pages'),
                      buildNumericTextField(_ratingsCountController, 'Ratings Count'),
                      buildNumericTextField(_textReviewsCountController, 'Text Reviews Count'),
                      buildTextField(_publicationDateController, 'Publication Date'),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (validateForm()) {
                            Book newBook = Book(
                              isbn: _isbnController.text,
                              title: _titleController.text,
                              authors: _authorController.text,
                              averageRating: double.parse(_averageRatingController.text),
                              numPages: int.parse(_numPagesController.text),
                              ratingsCount: int.parse(_ratingsCountController.text),
                              textReviewsCount: int.parse(_textReviewsCountController.text),
                              publication_date: int.parse(_publicationDateController.text),
                              bookImage: _imageController.text,
                            );

                            databaseService.addBook(newBook);

                            clearFormFields();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Book added successfully'),
                              ),
                            );
                          }
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
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildNumericTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  bool validateForm() {
    for (var controller in [
      _isbnController,
      _titleController,
      _authorController,
      _imageController,
      _averageRatingController,
      _numPagesController,
      _ratingsCountController,
      _textReviewsCountController,
      _publicationDateController,
    ]) {
      if (controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all the fields'),
          ),
        );
        return false;
      }
    }

    for (var controller in [
      _averageRatingController,
      _numPagesController,
      _ratingsCountController,
      _textReviewsCountController,
      _publicationDateController,
    ]) {
      try {
        double.parse(controller.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid numeric input'),
          ),
        );
        return false;
      }
    }

    return true;
  }

  void clearFormFields() {
    _isbnController.clear();
    _titleController.clear();
    _authorController.clear();
    _imageController.clear();
    _averageRatingController.clear();
    _numPagesController.clear();
    _ratingsCountController.clear();
    _textReviewsCountController.clear();
    _publicationDateController.clear();
  }
}
