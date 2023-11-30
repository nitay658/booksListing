import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:books_app/book_database.dart';

class AddBookPage extends StatefulWidget {
  final String userEmail;

  const AddBookPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  List<Book> _allbooks = [];
  List<Book> searchResults = [];
  late Set<Book> selectedBooks;
  late DatabaseService databaseService;
  final TextEditingController _textEditingController = TextEditingController();
  final StreamController<List<Book>> _searchController =
      BehaviorSubject<List<Book>>.seeded([]);

  @override
  void initState() {
    databaseService = DatabaseService(userEmail: widget.userEmail);
    _getToReadBooks();
    _textEditingController.addListener(_onSearchTextChanged);
    selectedBooks = {};
    super.initState();
  }

  @override
  void dispose() {
    _searchController.close();
    _textEditingController.dispose();
    super.dispose();
  }

  _onSearchTextChanged() {
    List<Book> filteredBooks = _allbooks
        .where((book) => book.title
            .toLowerCase()
            .contains(_textEditingController.text.toLowerCase()))
        .toList();
    _searchController.add(filteredBooks);
  }

  _getToReadBooks() {
    var lst = databaseService.getAllBooks();
    lst.listen((List<Book> run) {
      setState(() {
        _allbooks.addAll(run);
        searchResults = List.from(_allbooks);
        _searchController.add(searchResults);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21BFBD),
      appBar: AppBar(
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
      body: Container(
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
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
                          bool isSelected = selectedBooks.contains(book);
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
                              trailing: Checkbox(
                                key: Key(book.isbn), // Assuming Book has an id property
                                checkColor: Colors.white,
                                fillColor: MaterialStateProperty.resolveWith(getColor),
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      selectedBooks.add(book);
                                    } else {
                                      selectedBooks.remove(book);
                                    }
                                  });
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
                    _addSelectedBooksToList();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.plus_one_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  void _addSelectedBooksToList() {
    selectedBooks.forEach((element) {
      databaseService.addUserBook(element);
    });
    setState(() {
      selectedBooks.clear();
    });
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
