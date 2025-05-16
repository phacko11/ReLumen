import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/guide_profile_model.dart';

class GuideDetailScreen extends StatefulWidget {
  final String guideUid;

  const GuideDetailScreen({super.key, required this.guideUid});

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  Future<GuideProfile?>? _guideProfileFuture;

  @override
  void initState() {
    super.initState();
    _guideProfileFuture = _fetchGuideProfileDetails();
  }

  Future<GuideProfile?> _fetchGuideProfileDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('guide_profile') 
          .doc(widget.guideUid)
          .get();

      if (doc.exists) {
        return GuideProfile.fromSnapshot(doc);
      } else {
        print('Guide profile with UID ${widget.guideUid} does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching guide profile for UID ${widget.guideUid}: $e');
      return null;
    }
  }

  Widget _buildStarRating(double rating, int ratingCount, BuildContext context) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.4;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: 20));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: 20));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: 20));
      }
    }
    if (ratingCount > 0) {
      stars.add(const SizedBox(width: 6));
      stars.add(Text(
        '${rating.toStringAsFixed(1)} ($ratingCount ratings)',
        style: TextStyle(fontSize: 14, color: Colors.grey[700])
      ));
    } else {
      stars.add(const SizedBox(width: 6));
      stars.add(Text('(No ratings yet)', style: TextStyle(fontSize: 14, color: Colors.grey[700])));
    }
    return Row(children: stars);
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String content, TextStyle? contentStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor.withOpacity(0.8)),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                const SizedBox(height: 2.0),
                Text(content, style: contentStyle ?? const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat("#,##0", "vi_VN");

    return FutureBuilder<GuideProfile?>(
      future: _guideProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading Guide...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          String errorMessage = 'Could not load guide details.';
          if(snapshot.hasError) errorMessage = 'Error: ${snapshot.error}';
          if(!snapshot.hasData || snapshot.data == null) errorMessage = 'Guide not found or data is unavailable.';
          print(errorMessage);
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(errorMessage, textAlign: TextAlign.center),
            )),
          );
        }

        final GuideProfile guide = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(guide.displayName),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0), // Add more bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50, // Slightly larger avatar
                      backgroundColor: Colors.grey[300],
                      backgroundImage: guide.profileImageUrl != null && guide.profileImageUrl!.isNotEmpty
                          ? NetworkImage(guide.profileImageUrl!)
                          : null,
                      child: guide.profileImageUrl == null || guide.profileImageUrl!.isEmpty
                          ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.displayName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6.0),
                          _buildStarRating(guide.averageRating, guide.ratingCount, context),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                Text(
                  'About ${guide.displayName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Divider(height: 20, thickness: 1),
                Text(
                  guide.bio,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Colors.black87),
                ),
                const SizedBox(height: 24.0),

                if (guide.specialties.isNotEmpty) ...[
                  Text(
                    'Specialties',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 20, thickness: 1),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: guide.specialties
                        .map((specialty) => Chip(
                              label: Text(specialty),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24.0),
                ],

                if (guide.serviceAreas.isNotEmpty) ...[
                  Text(
                    'Service Areas',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 20, thickness: 1),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: guide.serviceAreas
                        .map((area) => Chip(label: Text(area)))
                        .toList(),
                  ),
                  const SizedBox(height: 24.0),
                ],
                
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Divider(height: 20, thickness: 1),
                _buildInfoRow(
                  icon: Icons.event_available_outlined,
                  title: 'Availability',
                  content: guide.availabilityNotes,
                ),
                
                if (guide.hourlyRate != null && guide.hourlyRate! > 0)
                   _buildInfoRow(
                      icon: Icons.payments_outlined,
                      title: 'Rate',
                      content: '${priceFormatter.format(guide.hourlyRate)} ${guide.currencyRate ?? 'VND'} / hour',
                      contentStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)
                   ),
                const SizedBox(height: 30.0),

                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.message_outlined),
                    label: const Text('Contact This Guide'),
                     style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact/Booking feature coming soon!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}