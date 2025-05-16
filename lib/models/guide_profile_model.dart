import 'package:cloud_firestore/cloud_firestore.dart';

class GuideProfile {
  final String uid;
  final String displayName;
  final String bio;
  final List<String> specialties;
  final List<String> serviceAreas;
  final num? hourlyRate;
  final String? currencyRate;
  final String availabilityNotes;
  final String? profileImageUrl;
  final bool isActive;
  final Timestamp? updatedAt;
  final double averageRating; 
  final int ratingCount;    

  GuideProfile({
    required this.uid,
    required this.displayName,
    required this.bio,
    required this.specialties,
    required this.serviceAreas,
    this.hourlyRate,
    this.currencyRate,
    required this.availabilityNotes,
    this.profileImageUrl,
    required this.isActive,
    this.updatedAt,
    this.averageRating = 0.0, 
    this.ratingCount = 0,    
  });

  factory GuideProfile.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuideProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? 'N/A',
      bio: data['bio'] ?? 'No bio provided.',
      specialties: List<String>.from(data['specialties'] ?? []),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      hourlyRate: data['hourlyRate'] as num?,
      currencyRate: data['currencyRate'] as String?,
      availabilityNotes: data['availabilityNotes'] ?? 'Availability not specified.',
      profileImageUrl: data['profileImageUrl'] as String?,
      isActive: data['isActive'] ?? false,
      updatedAt: data['updatedAt'] as Timestamp?,

      averageRating: (data['averageRating'] as num? ?? 0.0).toDouble(),
      ratingCount: (data['ratingCount'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'bio': bio,
      'specialties': specialties,
      'serviceAreas': serviceAreas,
      'hourlyRate': hourlyRate,
      'currencyRate': currencyRate,
      'availabilityNotes': availabilityNotes,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }
}