import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:service_app/model/app_constant.dart';
import 'package:service_app/model/contact_model.dart';
import 'package:service_app/model/conversation_model.dart';
import 'package:service_app/model/posting_model.dart';
import 'package:service_app/views/Host_Screens/book_listing_screen.dart';
import 'package:service_app/views/Widgets/posting_info_tile_ui.dart';
import 'package:service_app/views/conversation_screen.dart';

class ViewPostingScreen extends StatefulWidget {
  final PostingModel? posting;

  ViewPostingScreen({super.key, this.posting});

  @override
  State<ViewPostingScreen> createState() => _ViewPostingScreenState();
}

class _ViewPostingScreenState extends State<ViewPostingScreen> {
  late PostingModel posting;
  bool isLoading = true;

  Future<void> getRequiredInfo() async {
    try {
      await posting.getAllImagesFromStorage();
      await posting.getHostFromFirestore();
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    posting = widget.posting!;
    getRequiredInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
               colors: [Color(0xFF4A6CF7), Color(0xFF82C3FF)], // Blue gradient
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
            
            ),
          ),
        ),
        title: Text("Service Information",style: TextStyle(
          color: Colors.white
        ),),
       
actions: [
  IconButton(
    onPressed: () {
      if (posting.id != null && posting.id!.isNotEmpty) {
        AppConstants.currentUser.addSavedPosting(posting);
        Get.snackbar('Saved', 'Added to your saved list');
      } else {
        Get.snackbar('Failed to save', 'Posting ID is missing');
      }
    },
    icon: Icon(Icons.save, color: Colors.white),
  )
],


      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Listing Images
                  AspectRatio(
                    aspectRatio: 2 / 2,
                    child: posting.displayImages!.isEmpty
                        ? Container(
                            color: Colors.grey[200],
                            child: Center(child: Icon(Icons.image, size: 50)),
                          )
                        : PageView.builder(
                            itemCount: posting.displayImages!.length,
                            itemBuilder: (context, index) {
                              MemoryImage currentImage = posting.displayImages![index];
                              return Image(
                                image: currentImage,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(child: Icon(Icons.broken_image)),
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  // Posting Name button //booknow button
                  // description - profile pic
                  Padding(
                    padding: EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Posting Name button and book now
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.55,
                              child: Text(
                                posting.name!.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 3,
                              ),
                            ),

                            // book now button price
                            Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF4A6CF7), Color(0xFF82C3FF)],
                                      begin: FractionalOffset(0, 0),
                                      end: FractionalOffset(1, 0),
                                      stops: [0, 1],
                                      tileMode: TileMode.clamp,
                                    ),
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Get.to(BookListingScreen(posting: posting, hostID: posting!.host!.id!));
                                    },
                                    child: Text(
                                      "Book Now",
                                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Text(
                                  "\$${posting.price}/night",
                                  style: TextStyle(fontSize: 14),
                                )
                              ],
                            )
                          ],
                        ),

                        // description profile pic
                        Padding(
                          padding: EdgeInsets.only(top: 25, bottom: 25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.75,
                                child: Text(
                                  posting.description!,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 5,
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
    if (posting.host != null) {
      try {
        // Show loading indicator
        Get.dialog(
          Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        // Create a ContactModel for the host
        ContactModel hostContact = ContactModel(
          id: posting.host!.id,
          firstname: posting.host!.firstname,
          lastname: posting.host!.lastname,
        );

        // Initialize a new conversation
        ConversationModel conversation = ConversationModel();
        
        // Check if conversation already exists or create new one
        QuerySnapshot conversationSnapshot = await FirebaseFirestore.instance
            .collection("conversations")
            .where("userIDs", arrayContains: AppConstants.currentUser.id)
            .get();

        bool conversationExists = false;
        
        for (var doc in conversationSnapshot.docs) {
          List<String> userIDs = List<String>.from(doc["userIDs"] ?? []);
          if (userIDs.contains(posting.host!.id)) {
            // Existing conversation found
            await conversation.getConversationInfoFromFirestore(doc);
            conversationExists = true;
            break;
          }
        }

        if (!conversationExists) {
          // Create new conversation
          await conversation.addConversationToFirestore(hostContact);
        }

        // Close loading dialog
        if (Get.isDialogOpen!) Get.back();

        // Navigate to conversation screen
        Get.to(ConversationScreen(conversation: conversation));
      } catch (e) {
        // Close loading dialog if still open
        if (Get.isDialogOpen!) Get.back();
        
        Get.snackbar(
          'Error',
          'Could not start conversation: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
                                    },
                                    child: CircleAvatar(
                                      radius: MediaQuery.of(context).size.width / 12.5,
                                      backgroundColor: Colors.black,
                                      child: posting.host?.displayImage != null
                                          ? CircleAvatar(
                                              backgroundImage: posting.host!.displayImage,
                                              radius: MediaQuery.of(context).size.width / 13,
                                            )
                                          : CircleAvatar(
                                              radius: MediaQuery.of(context).size.width / 13,
                                              child: Icon(Icons.person),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      posting.host?.getFullNameofUser() ?? "Unknown",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // apartment bathroom
                  Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        PostingInfoTileUi(
                          iconData: Icons.water_damage,
                          category: posting.type!,
                          categoryInfo: "${posting.getGuestsNumber()} Request",
                        ),
                        PostingInfoTileUi(
                          iconData: Icons.design_services,
                          category: posting.type!,
                          categoryInfo: "${posting.getGuestsNumber()} Request",
                        ),
                        PostingInfoTileUi(
                          iconData: Icons.home_repair_service,
                          category: posting.type!,
                          categoryInfo: "${posting.getGuestsNumber()} Request",
                        ),
                      ],
                    ),
                  ),

                  // amenities
                  Text(
                    "Experiences:",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 25),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3.6,
                      shrinkWrap: true,
                      children: List.generate(
                        posting.amenities!.length,
                        (index) {
                          String currentAmenity = posting.amenities![index];
                          return Chip(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                currentAmenity,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            backgroundColor: Colors.white10,
                          );
                        },
                      ),
                    ),
                  ),

                  // location
                  Text(
                    "The Location:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(
                      posting.getFullAddress(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}