// lib/screens/create_edit_tour_screen.dart
import 'package:flutter/material.dart';
import '../models/tour_model.dart'; // Import Tour model

class CreateEditTourScreen extends StatefulWidget {
  final Tour? tourToEdit; // Nullable if creating a new tour

  const CreateEditTourScreen({super.key, this.tourToEdit});

  @override
  State<CreateEditTourScreen> createState() => _CreateEditTourScreenState();
}

class _CreateEditTourScreenState extends State<CreateEditTourScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tourToEdit == null ? 'Create New Tour' : 'Edit Tour'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.tourToEdit == null 
            ? 'Form to create a new tour will be here. Coming soon!'
            : 'Form to edit tour: ${widget.tourToEdit!.title} will be here. Coming soon!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}