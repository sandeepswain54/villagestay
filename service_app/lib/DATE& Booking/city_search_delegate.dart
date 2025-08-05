import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:service_app/DATE&%20Booking/nominatim_service.dart';
import 'package:service_app/Posting_Village/SearchResultsScreen.dart' show SearchResultsScreen;
 // Import your NominatimService

class CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Directly pass the query to SearchResultsScreen
    if (query.isNotEmpty) {
      return SearchResultsScreen(query: query);
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Enter a city, state, or hotel name'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: NominatimService.searchLocations(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ListView(
            children: [
              ListTile(
                title: Text(query),
                onTap: () {
                  close(context, query); // Allow custom query
                },
              ),
            ],
          );
        }

        final suggestions = snapshot.data!;

        return ListView.builder(
          itemCount: suggestions.length + 1, // +1 for custom query
          itemBuilder: (context, index) {
            if (index == 0) {
              // Allow user to search for the exact query
              return ListTile(
                title: Text(query),
                leading: Icon(Icons.search),
                onTap: () {
                  close(context, query); // Return the raw query
                },
              );
            }
            final suggestion = suggestions[index - 1];
            return ListTile(
              title: Text(suggestion['name']),
              subtitle: Text(suggestion['state']),
              onTap: () {
                close(context, suggestion['name']); // Return the selected city/state
              },
            );
          },
        );
      },
    );
  }
}