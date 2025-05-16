import 'package:flutter/material.dart';
import '../models/guide_profile_model.dart'; // Import GuideProfile model

class CreateEditGuideProfileScreen extends StatefulWidget {
  final GuideProfile? guideProfileToEdit; // Nullable if creating new

  const CreateEditGuideProfileScreen({super.key, this.guideProfileToEdit});

  @override
  State<CreateEditGuideProfileScreen> createState() => _CreateEditGuideProfileScreenState();
}

class _CreateEditGuideProfileScreenState extends State<CreateEditGuideProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guideProfileToEdit == null ? 'Create Guide Profile' : 'Edit Guide Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.guideProfileToEdit == null
            ? 'Form to create a new guide profile will be here. Coming soon!'
            : 'Form to edit guide profile: ${widget.guideProfileToEdit!.displayName} will be here. Coming soon!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}