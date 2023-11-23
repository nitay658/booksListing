// Import necessary packages and files
import 'package:books_app/bookToDataBase.dart';
import 'package:books_app/book_database.dart';
import 'package:books_app/knn_classifier.dart';
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
  late List<Book> _bookstoread = [];

  @override
  void initState() {
    currentPageIndex = 0;
    super.initState();
    userEmail = "nitayv658@gmail.com";
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
            label: 'RecommendationSystem',
          ),
        ],
      ),
      body: _buildPage(currentPageIndex),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHome();
      case 1:
        return _buildBooksToRead();
      case 2:
        return _buildReadedBook();
      case 3:
        return _buildRecommendationSystem();
      default:
        return Container();
    }
  }

  Widget _buildHome() {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Welcome!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontStyle: FontStyle.italic,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'This App is for Books Geeks Like myself, Hope you enjoy it!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontStyle: FontStyle.italic,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'If you don\'t find your book, you can add it!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontStyle: FontStyle.italic,
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Open a new widget
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBookToDataBasePage(
                    userEmail: userEmail,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Add a book to the DB.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksToRead() {return Container(
  margin: const EdgeInsets.all(16.0),
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
  child: Stack(
    alignment: Alignment.bottomLeft,
    children: [
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue[600], // Adjusted color to match the first container
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StreamBuilder<List<Book>>(
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
                            color: Colors.black,
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
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Author: ${book.authors}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
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
      ),
      // Floating Action Button
      Positioned(
        bottom: 16.0,
        left: 16.0,
        child: InkWell(
          onTap: () {
            setState(() {
              const Icon(Icons.book_online_outlined);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue, // Adjusted color to match the first container
            ),
            child: const Icon(
              Icons.book_online,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  ),
);
}

Widget _buildReadedBook() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF8B4513), // Brown color for wood
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: const Text(
        'ReadedBook',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}


  Widget _buildRecommendationSystem() {
    return Container(
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
                    return const CircularProgressIndicator();
                  } else if (recommendedBooksSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${recommendedBooksSnapshot.error}'),
                    );
                  } else if (!recommendedBooksSnapshot.hasData ||
                      recommendedBooksSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No recommended books available.'),
                    );
                  } else {
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
    );
  }

  Future<List<Book>> classifyReadBooks(List<Book> readBooks) async {
    await for (List<Book> allBooks in databaseService.getAllBooks()) {
      KnnClassifier knnClassifier = KnnClassifier();
      List<Book> recommendedBooks =
          knnClassifier.classifyList(allBooks, _bookstoread, k);
      return recommendedBooks;
    }
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: databaseService.getAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
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
                              setState(() {
                                if (!booksToAddToList.contains(book)) {
                                  booksToAddToList.add(book);
                                }
                              });
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
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
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
                Expanded(
                  child: ListView.builder(
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
                            setState(() {
                              booksToAddToList.remove(book);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    booksToAddToList.forEach((element) {
                      databaseService.addUserBook(element);
                    });
                    setState(() {
                      booksToAddToList.clear();
                    });
                  },
                  child: const Text('Add to List'),
                ),
              ],
            ),
          ),
        ],
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
