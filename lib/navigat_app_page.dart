// ignore: must_be_immutable
import 'package:books_app/book_database.dart';
import 'package:books_app/knn_classifier.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class NavigatAppPage extends StatefulWidget {
  const NavigatAppPage({Key? key}) : super(key: key);

  @override
  State<NavigatAppPage> createState() => _NavigatAppPageState();
}

class _NavigatAppPageState extends State<NavigatAppPage> {
  late int currentPageIndex;
  late String userEmail = "";
  late DatabaseService databaseService;
  final int k = 5;
  late List<Book> _bookstoread;

  @override
  void initState() {
    currentPageIndex = 0; // Assuming the default index is 0
    super.initState();
    userEmail =
        "nitayv658@gmail.com"; //TODO: Fix -> FirebaseAuth.instance.currentUser!.email!
    databaseService = DatabaseService(userEmail: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber[800],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_sharp),
            label: 'BookToRead',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book_online_outlined),
            icon: Icon(Icons.book_online),
            label: 'ReadedBook',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.school),
            icon: Icon(Icons.bookmark_add_outlined),
            label: 'ReccomndationSystem',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue[600],
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(0.1),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                  height: 10), // Add some space between title and paragraph
              Text(
                'This App is for Books Geeks Like myself, Hope you enjoy it!',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              StreamBuilder<List<Book>>(
                stream: databaseService.getBooksToRead(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: 301 ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      List<Book> bookstoread = snapshot.data!;
                      _bookstoread = bookstoread;
                      return ListView.builder(
                        itemCount: bookstoread.length,
                        itemBuilder: (context, index) {
                          Book book = bookstoread[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            child: ListTile(
                              dense: true,
                              leading: _buildBookImage(book.bookImage),
                              title: Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${book.numPages} Page',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    'Author: ${book.authors}',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                databaseService.addUserBook(book);
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('No books available.'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              // Floating Action Button
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to the screen where users can add new books
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBookPage(userEmail: userEmail),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.book_online),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('ReadedBook'),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: StreamBuilder<List<Book>>(
            stream: databaseService.getBooksRead(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  List<Book> readBooks = snapshot.data!;
                  return FutureBuilder<List<Book>>(
                    future: classifyReadBooks(readBooks),
                    builder: (context, recommendedBooksSnapshot) {
                      if (recommendedBooksSnapshot.connectionState ==
                              ConnectionState.waiting ||
                          recommendedBooksSnapshot.connectionState ==
                              ConnectionState.active) {
                        // If the Future is still running, show a loading indicator
                        return const CircularProgressIndicator();
                      } else if (recommendedBooksSnapshot.hasError) {
                        // If the Future encounters an error, display an error message
                        return Center(
                          child:
                              Text('Error: ${recommendedBooksSnapshot.error}'),
                        );
                      } else if (!recommendedBooksSnapshot.hasData ||
                          recommendedBooksSnapshot.data!.isEmpty) {
                        // If there is no data or the data is empty, display a message
                        return const Center(
                            child: Text('No recommended books available.'));
                      } else {
                        // If the Future is complete and there is data, display the ListView
                        List<Book> recommendedBooks =
                            recommendedBooksSnapshot.data!;
                        return ListView.builder(
                          itemCount: recommendedBooks.length,
                          itemBuilder: (context, index) {
                            Book book = recommendedBooks[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 7),
                              child: ListTile(
                                dense: true,
                                leading: _buildBookImage(book.bookImage),
                                title: Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${book.numPages} Page',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      'Author: ${book.authors}',
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Handle tap on recommended book
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No books available.'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ][currentPageIndex],
    );
  }

  Future<List<Book>> classifyReadBooks(List<Book> readBooks) async {
    await for (List<Book> allBooks in databaseService.getAllBooks()) {
      KnnClassifier knnClassifier = KnnClassifier(
        trainingData: allBooks,
      );
      List<Book> recommendedBooks = knnClassifier.classifyList(_bookstoread, k);

      return recommendedBooks;
    }

    // Return an empty list if the stream didn't emit any data
    return [];
  }
}

class AddBookPage extends StatefulWidget {
  final String userEmail;

  const AddBookPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  late String userEmail;
  late List<Book> booksToAddToList;
  late DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    booksToAddToList = [];
    databaseService = DatabaseService(userEmail: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
      ),
      body: Container(
        color: Colors.green,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            StreamBuilder<List<Book>>(
              stream: databaseService.getAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Display your database results here
                    List<Book> allBooks = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: allBooks.length,
                      itemBuilder: (context, index) {
                        Book book = allBooks[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          child: ListTile(
                            dense: true,
                            leading: _buildBookImage(book.bookImage),
                            title: Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${book.numPages} Page',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  'Author: ${book.authors}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Handle tap on book to add it to the list
                              if (!booksToAddToList.contains(book)) {
                                setState(() {
                                  booksToAddToList.add(book);
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            // Display the list of books to add to the right list
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Selected Books',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Display the books to add to the right list
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: booksToAddToList.length,
                      itemBuilder: (context, index) {
                        Book book = booksToAddToList[index];
                        return ListTile(
                          title: Text(book.title),
                          subtitle: Text('Author: ${book.authors}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              // Remove the book from the list
                              setState(() {
                                booksToAddToList.remove(book);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        booksToAddToList.forEach((element) {
                          databaseService.addUserBook(element);
                        });
                      },
                      child: const Text('Add to List'),
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
        color: Colors.green,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                Book book = books[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  child: ListTile(
                    dense: true,
                    leading: _buildBookImage(book.bookImage),
                    title: Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${book.numPages} Page',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'Author: ${book.authors}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle tap on book
                    },
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
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

Widget _buildBookImage(String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return Image.network(
      imageUrl,
      height: 250,
      fit: BoxFit.fill,
    );
  } else {
    return Image.asset(
        "assets/images/placeholder_image.jpg"); // Replace with your placeholder image asset
  }
}
