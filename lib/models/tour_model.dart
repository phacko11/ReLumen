// lib/models/tour_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Tour {
  final String id; // Document ID from Firestore
  final String title;
  final String description;
  final String locationName;
  final String imageUrl; 
  final num price;
  final String currency;
  final String duration;
  final String category;
  final String hostUid;
  final String hostName;
  final bool published;
  final Timestamp createdAt; // Should ideally not be nullable if always set
  final bool isFeatured; // To mark tours for suggestion

  Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.locationName,
    // this.geoLocation,
    required this.imageUrl,
    // this.images,
    required this.price,
    required this.currency,
    required this.duration,
    required this.category,
    required this.hostUid,
    required this.hostName,
    required this.published,
    required this.createdAt,
    this.isFeatured = false, // Default isFeatured to false
  });

  // Factory constructor to create a Tour instance from a Firestore document snapshot
  factory Tour.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Helper to safely get a Timestamp, defaulting to now if invalid or null
    Timestamp getTimestamp(dynamic value) {
        if (value is Timestamp) {
            return value;
        }
        // Attempt to parse if it's a Map (common issue if fromJson was used with toDate before toJson)
        // For fromSnapshot, direct Timestamp is expected. If it might be other types, more parsing needed.
        return Timestamp.now(); // Fallback, or handle error appropriately
    }

    return Tour(
      id: doc.id,
      title: data['title'] as String? ?? 'No Title Provided',
      description: data['description'] as String? ?? 'No Description Provided',
      locationName: data['locationName'] as String? ?? 'Unknown Location',
      // geoLocation: data['geoLocation'] as GeoPoint?,
      imageUrl: data['imageUrl'] as String? ?? '', // Default to empty if null
      // images: List<String>.from(data['images'] ?? []), // For later
      price: data['price'] as num? ?? 0,
      currency: data['currency'] as String? ?? 'VND',
      duration: data['duration'] as String? ?? 'N/A',
      category: data['category'] as String? ?? 'Uncategorized',
      hostUid: data['hostUid'] as String? ?? '',
      hostName: data['hostName'] as String? ?? 'Unknown Host',
      published: data['published'] as bool? ?? false,
      createdAt: getTimestamp(data['createdAt']), // Use helper for safety
      isFeatured: data['isFeatured'] as bool? ?? false, // Parse isFeatured, default to false
    );
  }

  // Method to convert Tour instance to a Map for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'locationName': locationName,
      // 'geoLocation': geoLocation,
      'imageUrl': imageUrl,
      // 'images': images,
      'price': price,
      'currency': currency,
      'duration': duration,
      'category': category,
      'hostUid': hostUid,
      'hostName': hostName,
      'published': published,
      'createdAt': createdAt, // Or FieldValue.serverTimestamp() when creating new
      'isFeatured': isFeatured,
      // 'updatedAt': FieldValue.serverTimestamp(), // Usually set this on update
    };
  }
}