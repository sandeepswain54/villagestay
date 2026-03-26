import 'dart:io';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'trip_model.dart';
import 'trip_detail_screen.dart';

class SwipeCardScreen extends StatefulWidget {
  final List<TripModel> initialTrips;
  final TripModel currentUser;

  const SwipeCardScreen({
    Key? key,
    required this.initialTrips,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<SwipeCardScreen> createState() => _SwipeCardScreenState();
}

class _SwipeCardScreenState extends State<SwipeCardScreen> {
  late MatchEngine _engine;
  final List<SwipeItem> _items = [];
  List<TripModel> likedProfiles = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    for (var trip in widget.initialTrips) {
      _items.add(
        SwipeItem(
          content: trip,
          likeAction: () {
            setState(() {
              likedProfiles.add(trip);
            });
            _showMatch();
          },
          nopeAction: () {
            debugPrint('Rejected: ${trip.name}');
          },
          onSlideUpdate: (_) => Future.value(),
          superlikeAction: () {
            setState(() {
              likedProfiles.add(trip);
            });
            _showSuperLike();
          },
        ),
      );
    }

    _engine = MatchEngine(swipeItems: _items);
  }

  void _showMatch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❤️ You liked this profile!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSuperLike() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⭐ Super Like!'),
        backgroundColor: Colors.amber,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Travel Buddy'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFF967BB6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body:
          widget.initialTrips.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sentiment_dissatisfied,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No matching profiles found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try adjusting your budget or dates',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF967BB6),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: SwipeCards(
                      matchEngine: _engine,
                      itemBuilder: (context, index) {
                        final trip = _items[index].content as TripModel;
                        return _buildSwipeCard(trip);
                      },
                      onStackFinished: () {
                        _showFinishDialog();
                      },
                      itemChanged: (item, idx) {
                        setState(() {
                          currentIndex = idx;
                        });
                      },
                      upSwipeAllowed: true,
                      fillSpace: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Reject Button
                          FloatingActionButton.extended(
                            onPressed: () {
                              final item = _engine.currentItem;
                              item?.nope();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Pass'),
                            backgroundColor: Colors.grey[400],
                          ),
                          // Super Like Button
                          FloatingActionButton(
                            onPressed: () {
                              final item = _engine.currentItem;
                              item?.superLike();
                            },
                            backgroundColor: Colors.amber,
                            child: const Icon(Icons.star, color: Colors.white),
                          ),
                          // Like Button
                          FloatingActionButton.extended(
                            onPressed: () {
                              final item = _engine.currentItem;
                              item?.like();
                            },
                            icon: const Icon(Icons.favorite),
                            label: const Text('Like'),
                            backgroundColor: Colors.red[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSwipeCard(TripModel trip) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
          ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            color: Colors.grey[300],
            child:
                trip.profileImage.startsWith('assets/')
                    ? Image.asset(trip.profileImage, fit: BoxFit.cover)
                    : trip.profileImage.startsWith('http')
                    ? Image.network(trip.profileImage, fit: BoxFit.cover)
                    : Image.file(File(trip.profileImage), fit: BoxFit.cover),
          ),
          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Profile Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Name and Age
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trip.age} • ${trip.gender}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trip.personalityType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trip.getLocation(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Travel Dates
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${trip.getTravelDays()} days • ₹${trip.budget}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    trip.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('All Profiles Reviewed'),
            content:
                likedProfiles.isEmpty
                    ? const Text('You didn\'t like anyone!')
                    : Text('You liked ${likedProfiles.length} profile(s)!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
    );
  }
}
