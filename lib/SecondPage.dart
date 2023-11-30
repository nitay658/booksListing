import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:books_app/book_database.dart';

import 'addBookPage.dart';

class SecondPage extends StatefulWidget {
  final String userEmail;
  const SecondPage({super.key, required this.userEmail});
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<Book> _bookstoread = [];
  List<Book> searchResults = [];
  final TextEditingController _textEditingController = TextEditingController();
  late StreamController<List<Book>> _searchController;

  @override
  void initState() {
    _searchController = BehaviorSubject<List<Book>>.seeded([]);
    _getToReadBooks();
    _textEditingController.addListener(_onSearchTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onSearchTextChanged);
    _searchController.close();
    _textEditingController.dispose();
    super.dispose();
  }

  _onSearchTextChanged() {
    List<Book> filteredBooks = _bookstoread
        .where((book) => book.title
            .toLowerCase()
            .contains(_textEditingController.text.toLowerCase()))
        .toList();
    _searchController.add(filteredBooks);
  }

  _getToReadBooks() async {
    var lst = DatabaseService(userEmail: widget.userEmail).getBooksToRead();
    
    //_searchController = BehaviorSubject<List<Book>>.seeded([]);
    //_searchController = BehaviorSubject<List<Book>>.seeded([]);
    lst.listen((List<Book> run) {
      setState(() {
        _bookstoread = [];
        _bookstoread.addAll(run);
        searchResults = List.from(_bookstoread);
        _searchController.add(searchResults);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF21BFBD),
        //backgroundColor: const Color(0xFF21BFBD),
        body: ListView(children: <Widget>[
          const SizedBox(height: 25.0),
          const Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: Row(
              children: <Widget>[
                Text('Your',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(width: 10.0),
                Text('Books To Read',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0))
              ],
            ),
          ),AppBar(backgroundColor:  const Color(0xFF21BFBD),
          title: CupertinoSearchTextField(
            backgroundColor: Colors.white,
            controller: _textEditingController,
            onChanged: (text) => _onSearchTextChanged(),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          centerTitle: true,
          elevation: 0,
        ),
          Container(
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
                const SizedBox(height: 40.0),
                Container(
                  height: MediaQuery.of(context).size.height - 185.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(75.0)),
                  ),
                  child: StreamBuilder<List<Book>>(
                    stream: _searchController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active ||
                          snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          List<Book> bookstoread = snapshot.data!;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      // Add code to remove the book from the list
                                      DatabaseService(
                                              userEmail: widget.userEmail)
                                          .removeUserBook(book);
                                      //_getToReadBooks();
                                      dispose();
                                      initState();
                                    },
                                  ),
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
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddBookPage(
                                    userEmail: widget.userEmail,
                                  )),
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
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
          ),
        ]));
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
        "assets/images/placeholder_image.jpg",
      ); // Replace with your placeholder image asset
    }
  }
}



