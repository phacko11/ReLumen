// lib/screens/become_partner_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecomePartnerScreen extends StatefulWidget {
  const BecomePartnerScreen({super.key});

  @override
  State<BecomePartnerScreen> createState() => _BecomePartnerScreenState();
}

class _BecomePartnerScreenState extends State<BecomePartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceDescriptionController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _serviceDescriptionController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Checkbox validation is handled by the FormField's validator

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: You are not logged in. Please log in again.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    try {
      Map<String, dynamic> partnerData = {
        'role': 'partner',
        'partnerInfo': {
          'serviceDescription': _serviceDescriptionController.text.trim(),
          'contactPhoneNumber': _contactPhoneController.text.trim().isNotEmpty 
                                ? _contactPhoneController.text.trim() 
                                : null, // Store as null if empty
        },
        'becamePartnerAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(currentUser.uid).set(
            partnerData,
            SetOptions(merge: true), // Merge with existing user document
          );

      print('User ${currentUser.uid} role updated to partner with additional info.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! You are now a ReLumen Partner.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Pop the screen to go back to UserProfileScreen
        // UserProfileScreen's .then() or onRefresh should update the UI
        Navigator.of(context).pop(); 
      }

    } catch (e) {
      print('Error submitting partner application: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a ReLumen Partner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Register to Offer Your Services',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide some basic information about the services you plan to offer on ReLumen. This will help us understand your offerings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 28.0),
              TextFormField(
                controller: _serviceDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Describe Your Services*',
                  hintText: 'e.g., Offer local cooking classes, guided city walks, unique craft workshops...',
                  border: OutlineInputBorder(),
                  helperText: 'Be specific about the cultural experiences you can provide.',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the services you intend to offer.';
                  }
                  if (value.trim().length < 30) { // Increased minimum length
                    return 'Please provide a more detailed description (at least 30 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone Number (Optional)',
                  hintText: 'Your phone number (e.g., 09xxxxxxxx)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24.0),
              FormField<bool>(
                builder: (FormFieldState<bool> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              if (mounted && value != null) {
                                setState(() {
                                  _agreedToTerms = value;
                                  state.didChange(value);
                                });
                              }
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                          Expanded(
                            child: InkWell( // Make text tappable to toggle checkbox
                              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                              child: const Text('I agree to the ReLumen Partner Terms and Conditions (placeholder).', style: TextStyle(fontSize: 14))
                            ),
                          ),
                        ],
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
                validator: (value) {
                  if (!_agreedToTerms) {
                    return 'You must agree to the terms and conditions to proceed.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              Center(
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Submit Application'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _submitApplication,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}