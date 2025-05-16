import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tour_model.dart'; 
import '../screens/tour_detail.dart';

class ToursListScreen extends StatelessWidget {
  const ToursListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cultural Tours'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tour')
            .where('published', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return const Center(child: Text('Something went wrong. Please try again.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tours available at the moment.'));
          }

          final List<Tour> tours = snapshot.data!.docs
              .map((doc) {
                try {
                  return Tour.fromSnapshot(doc);
                } catch (e) {
                  print("Error parsing tour document ${doc.id}: $e");
                  return null; 
                }
              })
              .where((tour) => tour != null)
              .cast<Tour>()
              .toList();

          if (tours.isEmpty) {
            return const Center(child: Text('Could not load tour data.'));
          }

          return ListView.builder(
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return TourCard(tour: tour);
            },
          );
        },
      ),
    );
  }
}

class TourCard extends StatelessWidget {
  final Tour tour;
  const TourCard({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
           Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailScreen(tourId: tour.id),
          ),
        );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (tour.imageUrl.isNotEmpty)
              Hero(
                tag: 'tour_image_${tour.id}', // For potential hero animations
                child: Image.network(
                  tour.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    print("Error loading image ${tour.imageUrl} for tour ${tour.id}: $exception");
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 48)),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tour.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    tour.locationName,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${NumberFormat("#,##0", "vi_VN").format(tour.price)} ${tour.currency}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                       Text(
                        tour.duration,
                        style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}