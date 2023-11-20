import 'package:books_app/book_database.dart';
import 'package:books_app/firebase_options.dart';
import 'package:books_app/navigat_app_page.dart';
import 'package:books_app/register_login.dart';
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      title: 'Books_Listing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NavigatAppPage(), //fix
    ),
  );
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(
//     const MaterialApp(
//       title: 'Your App Title',
//       home: YourHomePage(),
//     ),
//   );
// }

class YourHomePage extends StatelessWidget {
  const YourHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Build your UI here, and use the DatabaseService to perform database operations
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your App'),
      ),
      body: const AddBookToDataBasePage(userEmail:'nitayv@gmail.com'),
    );
  }
}

class YourDatabaseOperationsWidget extends StatelessWidget {
  const YourDatabaseOperationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the DatabaseService to perform database operations and display results
    return StreamBuilder<List<Book>>(
      stream: DatabaseService(userEmail: 'nitayv658@gmail.com').getAllBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Display your database results here
            List<Book> books = snapshot.data ?? [];
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                Book book = books[index];
                return ListTile(
                  leading: Image.network(
                    book.bookImage,
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                  ),
                  title: Text(book.title),
                  subtitle: Text('Author: ${book.authors}'),
                  // Add more widgets to display other book details
                );
              },
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
