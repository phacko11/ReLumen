// lib/screens/manage_guide_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/guide_profile_model.dart'; // Ensure path is correct
import 'create_edit_guide_profile.dart'; // Ensure path is correct

class ManageGuideProfileScreen extends StatefulWidget {
  const ManageGuideProfileScreen({super.key});

  @override
  State<ManageGuideProfileScreen> createState() => _ManageGuideProfileScreenState();
}

class _ManageGuideProfileScreenState extends State<ManageGuideProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  GuideProfile? _currentGuideProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchGuideProfile();
    } else {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) { // Check if can pop
          Navigator.of(context).pop(); 
        }
      });
    }
  }

  Future<void> _fetchGuideProfile() async {
    if (_currentUser == null || !mounted) return;
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot doc = await _firestore
          .collection('guide_profile') 
          .doc(_currentUser!.uid)
          .get();

      if (mounted) {
        if (doc.exists) {
          setState(() {
            _currentGuideProfile = GuideProfile.fromSnapshot(doc);
          });
        } else {
          setState(() {
            _currentGuideProfile = null;
          });
          print('No guide profile found for UID: ${_currentUser!.uid}');
        }
      }
    } catch (e) {
      print('Error fetching guide profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading guide profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatList(List<String>? list) {
    if (list == null || list.isEmpty) return 'Not specified';
    return list.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null && !_isLoading) { // Check _isLoading to avoid showing this during initial load
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Guide Profile')),
        body: const Center(child: Text('You need to be logged in to manage your guide profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Guide Profile'),
        actions: [
          if (!_isLoading) // Only show refresh if not already loading
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _fetchGuideProfile,
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentGuideProfile != null
              ? _buildProfileView(_currentGuideProfile!)
              : _buildCreateProfilePrompt(),
      floatingActionButton: _currentGuideProfile == null && !_isLoading
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_card_outlined), // Changed icon
              label: const Text('Create Guide Profile'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEditGuideProfileScreen()),
                ).then((success) { // CreateEdit screen might pop with true on success
                  if (success == true) _fetchGuideProfile();
                });
              },
            )
          : null,
    );
  }

  Widget _buildProfileView(GuideProfile guide) {
    final priceFormatter = NumberFormat("#,##0", "vi_VN");
    return RefreshIndicator( // Allow pull to refresh for existing profile
      onRefresh: _fetchGuideProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even if content is short
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: guide.profileImageUrl != null && guide.profileImageUrl!.isNotEmpty
                      ? NetworkImage(guide.profileImageUrl!)
                      : null,
                  child: guide.profileImageUrl == null || guide.profileImageUrl!.isEmpty
                      ? Icon(Icons.person_pin_circle_outlined, size: 45, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guide.displayName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(guide.isActive ? 'Profile Active' : 'Profile Inactive'),
                        backgroundColor: guide.isActive ? Colors.green[100] : Colors.orange[100],
                        labelStyle: TextStyle(color: guide.isActive ? Colors.green[800] : Colors.orange[800], fontWeight: FontWeight.w600),
                        avatar: Icon(guide.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline, color: guide.isActive ? Colors.green[700] : Colors.orange[700]),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildInfoTile(Icons.info_outline, 'Bio', guide.bio),
            _buildInfoTile(Icons.star_outline, 'Specialties', _formatList(guide.specialties)),
            _buildInfoTile(Icons.map_outlined, 'Service Areas', _formatList(guide.serviceAreas)),
            _buildInfoTile(Icons.event_available_outlined, 'Availability', guide.availabilityNotes),
            if (guide.hourlyRate != null && guide.hourlyRate! > 0)
              _buildInfoTile(
                Icons.payments_outlined,
                'Hourly Rate',
                '${priceFormatter.format(guide.hourlyRate)} ${guide.currencyRate ?? 'VND'}/hr',
              ),
            if (guide.updatedAt != null)
              _buildInfoTile(Icons.update_outlined, 'Last Updated', DateFormat('dd MMM, yyyy - hh:mm a').format(guide.updatedAt!.toDate())),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_note_rounded), // Changed icon
                label: const Text('Edit Guide Profile'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateEditGuideProfileScreen(guideProfileToEdit: guide),
                    ),
                  ).then((success) { // CreateEdit screen might pop with true on success
                     if (success == true) _fetchGuideProfile();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateProfilePrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1_outlined, size: 80, color: Theme.of(context).primaryColor.withOpacity(0.7)),
            const SizedBox(height: 20),
            const Text(
              'You haven\'t created a Local Guide profile yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
             const SizedBox(height: 10),
            const Text(
              'Create a profile to offer your guide services to travelers!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            // The FAB will serve as the primary create button in this state,
            // or you can add an ElevatedButton here too if FAB is not preferred.
            const SizedBox(height: 30),
             ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Create Your Guide Profile Now'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateEditGuideProfileScreen()),
                  ).then((success) {
                     if (success == true) _fetchGuideProfile();
                  });
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    if (subtitle.isEmpty || subtitle == 'Not specified') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}