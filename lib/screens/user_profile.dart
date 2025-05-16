// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login.dart';
import 'become_partner.dart'; 
import 'manage_tours.dart';   
import 'manage_guide_profile.dart'; 

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditingDisplayName = false;
  // _isUpdatingRole is no longer needed here as BecomePartnerScreen handles its own loading state
  late TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isEditingDisplayName = false; 
    });

    _currentUser = _auth.currentUser;

    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (mounted) {
          if (userDoc.exists) {
            _userData = userDoc.data() as Map<String, dynamic>?;
            _displayNameController.text = _getDisplayNameFromData();
            setState(() {}); 
          } else {
            print('User document does not exist in Firestore for UID: ${_currentUser!.uid}');
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile data not found.'), backgroundColor: Colors.orange),
            );
          }
        }
      } catch (e) {
        print('Error loading user data from Firestore: $e');
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error loading profile. Please check your connection.'), backgroundColor: Colors.red),
            );
        }
      }
    } else {
       print('No current user found from FirebaseAuth.');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDisplayName() async {
    if (_currentUser == null || _displayNameController.text.trim().isEmpty) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name cannot be empty.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    String newDisplayName = _displayNameController.text.trim();
    
    bool isCurrentlySavingName = _isLoading && _isEditingDisplayName;
    if (isCurrentlySavingName) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      await _currentUser!.updateDisplayName(newDisplayName);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'displayName': newDisplayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if(mounted) {
        setState(() {
          _userData?['displayName'] = newDisplayName; 
          _isEditingDisplayName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Error updating display name: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating display name: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }
  
  Future<void> _logout() async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    try { return DateFormat('dd MMM, yyyy').format(timestamp.toDate());}
    catch (e) { return 'Invalid Date'; }
  }

  String _getDisplayNameFromData() {
    final String firestoreDisplayName = _userData?['displayName'] as String? ?? '';
    if (firestoreDisplayName.isNotEmpty) return firestoreDisplayName;
    final String authDisplayName = _currentUser?.displayName ?? '';
    if (authDisplayName.isNotEmpty) return authDisplayName;
    final String email = _currentUser?.email ?? '';
    if (email.contains('@')) return email.split('@')[0];
    return ''; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isLoading)
            IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout)
        ],
      ),
      body: _isLoading && _userData == null
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Not logged in. Please log in again.', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                            ),
                            child: const Text("Go to Login"),
                        )
                      ],
                    )
                  )
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: <Widget>[
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _userData?['photoURL'] != null && (_userData!['photoURL'] as String).isNotEmpty
                              ? NetworkImage(_userData!['photoURL'] as String)
                              : null,
                          child: _userData?['photoURL'] == null || (_userData!['photoURL'] as String).isEmpty
                              ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      if (_isEditingDisplayName)
                        Column(
                          children: [
                            TextField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                labelText: 'Enter your display name',
                                border: OutlineInputBorder(),
                              ),
                              autofocus: true,
                              enabled: !_isLoading,
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _isLoading ? null : () {
                                    if(mounted) {
                                      setState(() {
                                        _isEditingDisplayName = false;
                                        _displayNameController.text = _getDisplayNameFromData();
                                      });
                                    }
                                  },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _updateDisplayName,
                                  child: _isLoading && _isEditingDisplayName
                                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                         : const Text('Save'),
                                ),
                              ],
                            )
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _getDisplayNameFromData().isNotEmpty ? _getDisplayNameFromData() : (_currentUser?.email?.split('@')[0] ?? 'User'),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!_isLoading) // Only show edit button if not globally loading
                              IconButton(
                                icon: Icon(Icons.edit_outlined, size: 22, color: Theme.of(context).primaryColor),
                                padding: const EdgeInsets.all(4.0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  if(mounted) {
                                    setState(() {
                                      _displayNameController.text = _getDisplayNameFromData();
                                      _isEditingDisplayName = true;
                                    });
                                  }
                                },
                                tooltip: 'Edit display name',
                              ),
                          ],
                        ),
                      const SizedBox(height: 8.0),
                      Center(
                        child: Text(
                          _currentUser?.email ?? 'No email associated',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Divider(thickness: 1),
                      const SizedBox(height: 12.0),
                      _buildProfileInfoRow(icon: Icons.verified_user_outlined, label: 'User ID (UID)', value: _currentUser?.uid ?? 'N/A'),
                      _buildProfileInfoRow(icon: Icons.badge_outlined, label: 'Role', value: _userData?['role']?.toString().toUpperCase() ?? 'USER'),
                      _buildProfileInfoRow(icon: Icons.calendar_today_outlined, label: 'Joined On', value: _formatTimestamp(_userData?['createdAt'] as Timestamp?)),
                      
                      // Display partner info if available
                      if (_userData?['partnerInfo'] != null && _userData?['partnerInfo'] is Map) ...[
                        const SizedBox(height: 12.0),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text("Partner Information", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        if ((_userData!['partnerInfo']['serviceDescription'] as String?)?.isNotEmpty ?? false)
                            _buildProfileInfoRow(icon: Icons.description_outlined, label: 'Services', value: _userData!['partnerInfo']['serviceDescription']),
                        if ((_userData!['partnerInfo']['contactPhoneNumber'] as String?)?.isNotEmpty ?? false)
                            _buildProfileInfoRow(icon: Icons.phone_outlined, label: 'Contact Phone', value: _userData!['partnerInfo']['contactPhoneNumber']),
                        if (_userData!['becamePartnerAt'] != null)
                            _buildProfileInfoRow(icon: Icons.star_border_outlined, label: 'Partner Since', value: _formatTimestamp(_userData!['becamePartnerAt'] as Timestamp?)),
                      ],

                      const SizedBox(height: 30.0),
                      
                      if ((_userData?['role'] ?? 'user') == 'user')
                        Center(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.star_border_purple500_outlined),
                            label: const Text('Become a ReLumen Partner'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              foregroundColor: Theme.of(context).colorScheme.secondary,
                              side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
                            ),
                            onPressed: _isLoading ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BecomePartnerScreen()),
                              ).then((value) {
                                // Value can be true if partner status was successfully updated, or just refresh regardless
                                print("Returned from BecomePartnerScreen, refreshing profile...");
                                _loadUserProfile(); // Refresh profile after returning
                              });
                            },
                          ),
                        )
                      else if ((_userData?['role'] == 'partner')) ...[
                         Center(
                           child: Padding(
                             padding: const EdgeInsets.only(bottom: 20.0), // Added bottom padding
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.verified_user_rounded, color: Colors.green[700], size: 20), // Changed icon
                                 const SizedBox(width: 8),
                                 Text('You are a ReLumen Partner!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
                               ],
                             ),
                           ),
                         ),
                         Text("Partner Dashboard", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 10.0),
                         ElevatedButton.icon(
                            icon: const Icon(Icons.article_outlined),
                            label: const Text('Manage My Tours'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)), // Full width
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageToursScreen()));
                            },
                         ),
                         const SizedBox(height: 10.0),
                         ElevatedButton.icon(
                            icon: const Icon(Icons.badge_outlined), // Changed icon for consistency
                            label: const Text('Manage My Guide Profile'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)), // Full width
                            onPressed: () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageGuideProfileScreen()));
                            },
                         ),
                      ],
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
        );
  }

  Widget _buildProfileInfoRow({required IconData icon, required String label, required String value}) {
    if (value.isEmpty || value == 'N/A') return const SizedBox.shrink(); // Don't show row if value is empty
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align icon and text block to top
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16.0),
          Text('$label:', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(width: 8.0),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }
}