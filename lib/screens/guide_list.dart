import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guide_profile_model.dart';
import 'package:intl/intl.dart'; 
import 'guide_detail.dart';

class GuidesListScreen extends StatelessWidget {
  const GuidesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Local Guides'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guide_profile') 
            .where('isActive', isEqualTo: true)
            .orderBy('averageRating', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Firestore Error loading guides: ${snapshot.error}");
            if (snapshot.error.toString().contains("requires an index")) {
                 return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${snapshot.error}\n\nFirestore needs a custom index for this query. Please check the debug console for a link to create it in the Firebase console.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
            }
            return const Center(child: Text('Something went wrong. Please try again.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No local guides available at the moment.'));
          }

          final List<GuideProfile> guides = snapshot.data!.docs
              .map((doc) {
                try {
                  return GuideProfile.fromSnapshot(doc);
                } catch (e) {
                  print("Error parsing guide profile ${doc.id}: $e");
                  return null;
                }
              })
              .where((guide) => guide != null)
              .cast<GuideProfile>()
              .toList();

          if (guides.isEmpty) {
            return const Center(child: Text('Could not load guide data.'));
          }

          return ListView.builder(
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              return GuideCard(guide: guide);
            },
          );
        },
      ),
    );
  }
}

class GuideCard extends StatelessWidget {
  final GuideProfile guide;
  const GuideCard({super.key, required this.guide});

  // Helper function to build star rating display
  Widget _buildStarRating(double rating, int ratingCount, BuildContext context) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    if (ratingCount > 0) {
      stars.add(const SizedBox(width: 4));
      stars.add(Text('($ratingCount)', style: TextStyle(fontSize: 12, color: Colors.grey[600])));
    } else {
      stars.add(const SizedBox(width: 4));
      stars.add(Text('(No ratings yet)', style: TextStyle(fontSize: 12, color: Colors.grey[600])));
    }
    return Row(children: stars);
  }


  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat("#,##0", "vi_VN"); 

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideDetailScreen(guideUid: guide.uid), 
          ),
        );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[300],
                backgroundImage: guide.profileImageUrl != null && guide.profileImageUrl!.isNotEmpty
                    ? NetworkImage(guide.profileImageUrl!)
                    : null,
                child: guide.profileImageUrl == null || guide.profileImageUrl!.isEmpty
                    ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      guide.displayName,
                      style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    _buildStarRating(guide.averageRating, guide.ratingCount, context),
                    const SizedBox(height: 6.0),
                    // ---------------------------
                    if (guide.specialties.isNotEmpty)
                      Text(
                        'Specialties: ${guide.specialties.join(", ")}',
                        style: TextStyle(fontSize: 13.0, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4.0),
                    Text(
                      guide.bio,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    if (guide.hourlyRate != null && guide.hourlyRate! > 0)
                      Text(
                        'Rate: ${priceFormatter.format(guide.hourlyRate)} ${guide.currencyRate ?? 'VND'}/hr',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}