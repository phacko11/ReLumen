
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import '../models/tour_model.dart'; 

class TourDetailScreen extends StatefulWidget {
  final String tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  Future<Tour?>? _tourFuture;

  @override
  void initState() {
    super.initState();
    _tourFuture = _fetchTourDetails();
  }

  Future<Tour?> _fetchTourDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tour') // Ensure this is your correct tours collection name
          .doc(widget.tourId)
          .get();

      if (doc.exists) {
        return Tour.fromSnapshot(doc);
      } else {
        print('Tour document with ID ${widget.tourId} does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching tour details for ID ${widget.tourId}: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat("#,##0", "vi_VN");

    return FutureBuilder<Tour?>(
      future: _tourFuture,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold( // Show a scaffold during loading for consistent AppBar behavior
            appBar: AppBar(title: const Text('Loading Tour...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error state or no data
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          String errorMessage = 'Could not load tour details.';
          if (snapshot.hasError) {
            errorMessage = 'Error: ${snapshot.error}';
          } else if (!snapshot.hasData || snapshot.data == null) {
            errorMessage = 'Tour not found or data is unavailable.';
          }
          print(errorMessage); // Log the error
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(errorMessage, textAlign: TextAlign.center),
              ),
            ),
          );
        }

        // Data fetched successfully
        final Tour tour = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(tour.title), // Dynamic title from the fetched tour
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Tour Image
                if (tour.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      tour.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 50, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16.0),

                // Location
                _buildDetailRow(
                    icon: Icons.location_on_outlined, text: tour.locationName),
                const SizedBox(height: 8.0),

                // Duration
                _buildDetailRow(
                    icon: Icons.timer_outlined, text: tour.duration),
                const SizedBox(height: 8.0),

                // Category
                _buildDetailRow(
                    icon: Icons.category_outlined, text: tour.category),
                const SizedBox(height: 8.0),

                // Host
                _buildDetailRow(
                    icon: Icons.person_outline,
                    text: 'Hosted by: ${tour.hostName}'),
                const SizedBox(height: 16.0),

                // Price
                Text(
                  'Price: ${priceFormatter.format(tour.price)} ${tour.currency}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 16.0),

                // Description Section Title
                Text(
                  'About This Tour',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                // Description Text
                Text(
                  tour.description,
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24.0),

                // Placeholder for Booking Button
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Book This Tour (Coming Soon)'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Booking feature is not yet implemented.')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0), // Extra space at the bottom
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget to build detail rows with an icon and text
  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10.0),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 16, color: Colors.grey[850]))),
      ],
    );
  }
}