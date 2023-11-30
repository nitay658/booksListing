import 'dart:math';

import 'book_database.dart';

class KnnClassifier {
  late List<Book> _trainingData;
  final double weightAverageRating = 1.0;
  final double weightRatingsCount = 1.0;
  final double weightTextReviewsCount = 1.0;
  final double weightAuthors = 3.0;

  KnnClassifier();

  List<Book> classifyList(List<Book> trainingData, List<Book> books, int k) {
    _trainingData = trainingData;
    List<Book> classifications = [];

    for (var book in books) {
      // Check if the book is not already in the recommendations list
      //if (!classifications.any((b) => b.isbn == book.isbn)) {
        Book classification = classify(book, k);
        if (!books.any((b) => b.isbn == classification.isbn)) {
          classifications.add(classification);
        }
      //}
    }

    return classifications;
  }

  Book classify(Book data, int k) {
    final List<Map<String, dynamic>> distances = [];

    for (var trainingPoint in _trainingData) {
      if (data.isbn != trainingPoint.isbn) {
        final double distance = calculateDistance(data, trainingPoint);
        distances.add({'distance': distance, 'target': trainingPoint});
      }
    }

    distances.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    final List<Book> neighbors =
        distances.sublist(0, k).map((e) => e['target'] as Book).toList();

    // Combine information from neighbors
    return combineNeighbors(neighbors);
  }

  Book combineNeighbors(List<Book> neighbors) {
    // Implement a more sophisticated way to combine information from neighbors
    // For now, just return the first neighbor as an example
    return neighbors.isNotEmpty ? neighbors.first : Book.empty();
  }

double calculateDistance(Book data1, Book data2) {
  double diffAverageRating =
      (data1.averageRating - data2.averageRating) * weightAverageRating;
  double diffRatingsCount =
      (data1.ratingsCount - data2.ratingsCount) * weightRatingsCount;
  double diffTextReviewsCount =
      (data1.textReviewsCount - data2.textReviewsCount) *
          weightTextReviewsCount;
  double diffAuthors = calculateAuthorDifference(data1.authors, data2.authors) * weightAuthors;

  double distance = sqrt(pow(diffAverageRating, 2) +
      pow(diffRatingsCount, 2) +
      pow(diffTextReviewsCount, 2) +
      pow(diffAuthors, 2));

  return distance;
}

double calculateAuthorDifference(String author1, String author2) {
  // You can customize this function to calculate the difference between authors.
  // For simplicity, let's consider them similar if they are the same.
  return (author1 == author2) ? 0.0 : 2.0;
}

}
