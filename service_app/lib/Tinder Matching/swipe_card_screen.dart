import 'dart:io';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'trip_model.dart';
import 'trip_detail_screen.dart';

class SwipeCardScreen extends StatefulWidget {
  final List<TripModel> initialTrips;

  const SwipeCardScreen({Key? key, required this.initialTrips}) : super(key: key);

  @override
  State<SwipeCardScreen> createState() => _SwipeCardScreenState();
}

class _SwipeCardScreenState extends State<SwipeCardScreen> {
  late MatchEngine _engine;
  final List<SwipeItem> _items = [];

  @override
  void initState() {
    super.initState();

    for (var trip in widget.initialTrips) {
      _items.add(SwipeItem(
        content: trip,
        likeAction: () {},
        nopeAction: () {},
        onSlideUpdate: (_) => Future.value(),
        superlikeAction: () {},
      ));
    }

    _engine = MatchEngine(swipeItems: _items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swipe Matching Trips")),
      body: widget.initialTrips.isEmpty
          ? const Center(child: Text("No matching trips found"))
          : SwipeCards(
              matchEngine: _engine,
              itemBuilder: (context, index) {
                final trip = _items[index].content as TripModel;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetailScreen(trip: trip),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(trip.imagePaths.first),
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        child: Text(
                          "${trip.name}\n₹${trip.budget}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onStackFinished: () => const Center(child: Text("No more trips")),
              itemChanged: (item, idx) {},
              upSwipeAllowed: true,
              fillSpace: true,
            ),
    );
  }
}
