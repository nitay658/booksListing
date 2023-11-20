import 'dart:math';

import 'book_database.dart';

class KnnClassifier {
  final List<Book> trainingData;
  final double weightAverageRating = 1.0;
  final double weightRatingsCount = 1.0;
  final double weightTextReviewsCount = 1.0;
  final double weightAuthors = 2.0;

  KnnClassifier({
    required this.trainingData,
  });

  List<Book> classifyList(List<Book> books, int k) {
    List<Book> classifications = [];

    for (var book in books) {
      Book classification = classify(book, k);
      if (!books.contains(classification)) {
        classifications.add(classification);
      }
    }

    return classifications;
  }

  Book classify(Book data, int k) {
    final List<Map<String, dynamic>> distances = [];

    for (var trainingPoint in trainingData) {
      if (data.isbn != trainingPoint.isbn) {
        final double distance = calculateDistance(data, trainingPoint);
        distances.add({'distance': distance, 'target': trainingPoint});
      }
    }

    distances.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    final List<Book> neighbors =
        distances.sublist(0, k).map((e) => e['target'] as Book).toList();

    // Optionally, you might want to implement a more sophisticated way to combine information from neighbors
    // For now, just return the first neighbor as an example
    return neighbors.isNotEmpty ? neighbors.first : data;
  }

  double calculateDistance(Book data1, Book data2) {
    double diffAverageRating =
        (data1.averageRating - data2.averageRating) * weightAverageRating;
    double diffRatingsCount =
        (data1.ratingsCount - data2.ratingsCount) * weightRatingsCount;
    double diffTextReviewsCount =
        (data1.textReviewsCount - data2.textReviewsCount) *
            weightTextReviewsCount;
    double diffAuthors =
        (data1.authors == data2.authors) ? 0.0 : 1.0 * weightAuthors;

    double distance = sqrt(pow(diffAverageRating, 2) +
        pow(diffRatingsCount, 2) +
        pow(diffTextReviewsCount, 2) +
        pow(diffAuthors, 2));

    return distance;
  }
}
