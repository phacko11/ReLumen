// lib/screens/manage_tours_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_model.dart';
import 'create_edit_tour.dart'; 

class ManageToursScreen extends StatefulWidget {
  const ManageToursScreen({super.key});

  @override
  State<ManageToursScreen> createState() => _ManageToursScreenState();
}

class _ManageToursScreenState extends State<ManageToursScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      // This should ideally be handled by routing logic before reaching this screen
      // For example, if AuthWrapper protects routes that require login.
      // If somehow user reaches here without being logged in, navigate them away.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the very first screen (e.g. AuthWrapper/Login)
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage My Tours')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You need to be logged in to manage tours.'),
              SizedBox(height: 10),
              // Optionally, add a button to go to login if appropriate
            ],
          )
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Tours'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tours')
            .where('hostUid', isEqualTo: _currentUser!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error loading partner's tours: ${snapshot.error}");
            return Center(child: Text('Error loading your tours: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tour_outlined, size: 70, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      'You haven\'t created any tours yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create Your First Tour'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateEditTourScreen()),
                        ).then((result) {
                           if (result == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Tour operation successful!'), backgroundColor: Colors.green)
                               );
                           }
                        });
                      },
                    )
                  ],
                ),
              )
            );
          }

          final List<Tour> partnerTours = snapshot.data!.docs
              .map((doc) {
                try { return Tour.fromSnapshot(doc); }
                catch (e) {
                  print("Error parsing partner tour ${doc.id}: $e");
                  return null;
                }
              })
              .where((tour) => tour != null)
              .cast<Tour>()
              .toList();
          
          if (partnerTours.isEmpty && snapshot.data!.docs.isNotEmpty) {
             return const Center(child: Text('Could not display your tours due to a data error.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: partnerTours.length,
            itemBuilder: (context, index) {
              final tour = partnerTours[index];
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  leading: tour.imageUrl.isNotEmpty
                      ? SizedBox(
                          width: 70, // Fixed width for leading image
                          height: 60, // Fixed height
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Image.network(
                              tour.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          width: 70, height: 60, 
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6.0)
                          ),
                          child: const Icon(Icons.image_not_supported_outlined, size: 30, color: Colors.grey)
                        ),
                  title: Text(tour.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(tour.locationName, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${tour.published ? "Published" : "Draft"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: tour.published ? Colors.green[700] : Colors.orange[700],
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.edit_note_outlined, color: Theme.of(context).primaryColor, size: 28),
                      tooltip: 'Edit Tour',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEditTourScreen(tourToEdit: tour),
                          ),
                        ).then((result){
                           if (result == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Tour operation successful!'), backgroundColor: Colors.green)
                               );
                           }
                        });
                      },
                    ),
                  isThreeLine: true, // Allows more space for subtitle
                  onTap: () { // Also navigate to edit on tap
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEditTourScreen(tourToEdit: tour),
                      ),
                    ).then((result){
                       if (result == true && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Tour operation successful!'), backgroundColor: Colors.green)
                           );
                       }
                    });
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 4), // Spacing between cards
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Create New Tour'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEditTourScreen()),
          ).then((result){
             if (result == true && mounted) { // Assuming CreateEditTourScreen pops with true on successful creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour operation successful!'), backgroundColor: Colors.green)
                );
             }
          });
        },
      ),
    );
  }
}