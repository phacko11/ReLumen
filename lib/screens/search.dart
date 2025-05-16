// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tour_model.dart';
import '../models/guide_profile_model.dart';
import 'tour_list.dart'; 
import 'guide_list.dart'; 
import 'ai_assistant.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoading = false;
  bool _isLoadingSuggestions = true;
  List<Tour> _foundTours = [];
  List<GuideProfile> _foundGuides = [];
  List<Tour> _suggestedTours = [];
  bool _hasInitiatedSearch = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSuggestions();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty && _searchQuery.isNotEmpty) {
        if (mounted) {
          setState(() {
            _searchQuery = "";
            _hasInitiatedSearch = false;
            _foundTours = [];
            _foundGuides = [];
          });
        }
      } else if (_searchController.text.isNotEmpty) {
         // User is typing, consider this as initiating a search for UI purposes
         if (mounted) {
            setState(() {
                 _searchQuery = _searchController.text; // Keep searchQuery updated
                 _hasInitiatedSearch = true; 
            });
         }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSuggestions() async {
    if (!mounted) return;
    setState(() => _isLoadingSuggestions = true);
    try {
      QuerySnapshot tourSnapshot = await FirebaseFirestore.instance
          .collection('tours')
          .where('published', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(5)
          .get();
      if (mounted) {
        setState(() {
          _suggestedTours = tourSnapshot.docs
              .map((doc) => Tour.fromSnapshot(doc))
              .toList();
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print("Error loading suggested tours: $e");
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    final String trimmedQuery = query.trim();

    setState(() {
      _searchQuery = trimmedQuery; // Use trimmed query
      _isLoading = true;
      _hasInitiatedSearch = true;
      _foundTours = [];
      _foundGuides = [];
    });

    if (trimmedQuery.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      QuerySnapshot tourSnapshot = await FirebaseFirestore.instance
          .collection('tours')
          .where('published', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: trimmedQuery)
          .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
          .limit(10)
          .get();
      if (mounted) {
        _foundTours = tourSnapshot.docs.map((doc) => Tour.fromSnapshot(doc)).toList();
      }

      QuerySnapshot guideSnapshot = await FirebaseFirestore.instance
          .collection('guide_profile')
          .where('isActive', isEqualTo: true)
          .where('displayName', isGreaterThanOrEqualTo: trimmedQuery)
          .where('displayName', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
          .limit(10)
          .get();
      if (mounted) {
        _foundGuides = guideSnapshot.docs.map((doc) => GuideProfile.fromSnapshot(doc)).toList();
      }
    } catch (e) {
      print("Error during search: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error performing search: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tours, guides, culture...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            // Update _searchQuery as user types for immediate UI feedback if needed
            // Actual search triggered by onSubmitted or search icon
            if (mounted) {
              setState(() {
                _searchQuery = value;
                if (value.isEmpty && _hasInitiatedSearch) {
                  // If user clears text after a search, revert to suggestions view
                  _hasInitiatedSearch = false; 
                  _foundTours = [];
                  _foundGuides = [];
                } else if (value.isNotEmpty) {
                  _hasInitiatedSearch = true; // Any typing means user intends to search
                }
              });
            }
          },
          onSubmitted: (value) => _performSearch(value),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                if (mounted) {
                  setState(() {
                    _searchQuery = "";
                    _hasInitiatedSearch = false;
                    _foundTours = [];
                    _foundGuides = [];
                  });
                }
              },
            ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (!_hasInitiatedSearch && _searchQuery.isEmpty) {
      return _buildInitialSuggestions();
    } else if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_searchQuery.isNotEmpty && _foundTours.isEmpty && _foundGuides.isEmpty) {
      return Center(child: Text('No results found for "$_searchQuery".'));
    } else if (_foundTours.isNotEmpty || _foundGuides.isNotEmpty) {
      return _buildSearchResultsList();
    } else {
      // Fallback to suggestions if query is empty and no results were found (e.g., after clearing a fruitless search)
      return _buildInitialSuggestions();
    }
  }

  Widget _buildInitialSuggestions() {
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    // --- BỎ `const` Ở ĐÂY ---
    final List<Map<String, dynamic>> interestingPrompts = [
      {'type': 'fact', 'text': 'Did you know? Vietnamese Dong Son drums are over 2000 years old!', 'icon': Icons.lightbulb_outline, 'color': Colors.amber},
      {'type': 'tip', 'text': 'Tip: When visiting pagodas, dress respectfully (cover shoulders and knees).', 'icon': Icons.restaurant_menu_outlined, 'color': Colors.green},
      // Sử dụng context hợp lệ ở đây
      {'type': 'ai_prompt', 'text': 'Ask Luminas: "Tell me about Ao Dai."', 'icon': Icons.chat_bubble_outline, 'color': Theme.of(context).colorScheme.secondary},
      {'type': 'ai_prompt', 'text': 'Ask Luminas: "Unique markets in Saigon?"', 'icon': Icons.chat_bubble_outline, 'color': Theme.of(context).colorScheme.secondary},
    ];
    // -----------------------

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (_suggestedTours.isNotEmpty) ...[
          Text('Featured Tours', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedTours.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.7, // Adjusted width
                  margin: const EdgeInsets.only(right: 12.0),
                  child: TourCard(tour: _suggestedTours[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text('Discover & Ask Luminas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...interestingPrompts.map((promptData) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: Icon(promptData['icon'] as IconData, color: promptData['color'] as Color, size: 28),
              title: Text(promptData['text'] as String, style: const TextStyle(fontSize: 15)),
              trailing: promptData['type'] == 'ai_prompt' ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey) : null,
              onTap: promptData['type'] == 'ai_prompt'
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AiAssistantScreen(initialPrompt: (promptData['text'] as String).replaceFirst("Ask Luminas: ", "")),
                        ),
                      );
                    }
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchResultsList() {
    List<Widget> searchResultWidgets = [];
    if (_foundTours.isNotEmpty) {
      searchResultWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text('Tours matching "$_searchQuery"', style: Theme.of(context).textTheme.titleLarge),
        )
      );
      searchResultWidgets.addAll(_foundTours.map((tour) => TourCard(tour: tour)).toList());
    }

    if (_foundGuides.isNotEmpty) {
      searchResultWidgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, _foundTours.isNotEmpty ? 24.0 : 16.0, 16.0, 8.0),
          child: Text('Guides matching "$_searchQuery"', style: Theme.of(context).textTheme.titleLarge),
        )
      );
      searchResultWidgets.addAll(_foundGuides.map((guide) => GuideCard(guide: guide)).toList());
    }
    
    // This condition should ideally not be met if _buildBodyContent logic is correct
    if (searchResultWidgets.isEmpty && !_isLoading) {
        return Center(child: Text('No results found for "$_searchQuery".'));
    }

    return ListView(
      children: searchResultWidgets,
    );
  }
}