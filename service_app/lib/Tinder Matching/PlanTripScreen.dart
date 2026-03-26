import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'trip_model.dart';
import 'trip_data.dart';
import 'swipe_card_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedState;
  String? selectedDistrict;
  String? selectedVillage;
  String? selectedPersonality;
  String selectedGender = 'Male';

  DateTime? _startDate;
  DateTime? _endDate;
  List<File> selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedState = stateDistricts.keys.first;
    selectedDistrict = stateDistricts[selectedState]!.first;
    selectedVillage = districtVillages[selectedDistrict]!.keys.first;
    selectedPersonality = personalityTypes.first;
  }

  Future<void> _pickImages() async {
    final List<XFile>? picked = await picker.pickMultiImage(imageQuality: 60);
    if (picked != null) {
      setState(() {
        selectedImages = picked.map((img) => File(img.path)).toList();
      });
    }
  }

  Future<void> _pickDate(bool isStart) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate:
            isStart
                ? (_startDate ?? DateTime.now())
                : (_endDate ?? DateTime.now()),
        firstDate: DateTime.now(),
        lastDate: DateTime(2026, 12, 31),
      );
      if (picked != null) {
        setState(() {
          if (isStart) {
            _startDate = picked;
            // If end date is before start date, clear it
            if (_endDate != null && _endDate!.isBefore(picked)) {
              _endDate = null;
            }
          } else {
            _endDate = picked;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking date: $e');
    }
  }

  void _onStateChanged(String? newState) {
    if (newState != null) {
      setState(() {
        selectedState = newState;
        selectedDistrict = stateDistricts[newState]!.first;
        selectedVillage = districtVillages[selectedDistrict]!.keys.first;
      });
    }
  }

  void _onDistrictChanged(String? newDistrict) {
    if (newDistrict != null) {
      setState(() {
        selectedDistrict = newDistrict;
        selectedVillage = districtVillages[newDistrict]!.keys.first;
      });
    }
  }

  Future<void> _submitTrip() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select travel dates')),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String tripId = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> localImagePaths = [];

      // Save images to local storage
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final tripDir = Directory('${appDir.path}/travel_profiles/$tripId');

        // Create directory if it doesn't exist
        if (!await tripDir.exists()) {
          await tripDir.create(recursive: true);
        }

        // Copy selected images to local directory
        for (int i = 0; i < selectedImages.length; i++) {
          try {
            final fileName = 'image_$i.jpg';
            final savedImage = await selectedImages[i].copy(
              '${tripDir.path}/$fileName',
            );
            localImagePaths.add(savedImage.path);
          } catch (e) {
            debugPrint('Error saving image $i: $e');
            // Continue even if image save fails
          }
        }
      } catch (e) {
        debugPrint('Error accessing local storage: $e');
      }

      // Create trip model with local image paths
      final newTrip = TripModel(
        id: tripId,
        name: nameController.text.trim(),
        profileImage:
            localImagePaths.isNotEmpty
                ? localImagePaths[0]
                : 'assets/default_profile.png',
        description: descController.text.trim(),
        budget: int.parse(budgetController.text.trim()),
        startDate: _startDate!,
        endDate: _endDate!,
        state: selectedState!,
        district: selectedDistrict!,
        village: selectedVillage!,
        personalityType: selectedPersonality!,
        age: int.parse(ageController.text.trim()),
        gender: selectedGender,
        imagePaths: localImagePaths,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('travel_users')
          .doc(tripId)
          .set({
            'id': tripId,
            'name': newTrip.name,
            'profileImage': newTrip.profileImage,
            'description': newTrip.description,
            'budget': newTrip.budget,
            'startDate': Timestamp.fromDate(newTrip.startDate),
            'endDate': Timestamp.fromDate(newTrip.endDate),
            'state': newTrip.state,
            'district': newTrip.district,
            'village': newTrip.village,
            'personalityType': newTrip.personalityType,
            'age': newTrip.age,
            'gender': newTrip.gender,
            'imagePaths': localImagePaths,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Fetch matching profiles from Firestore
      final matchingSnapshot =
          await FirebaseFirestore.instance.collection('travel_users').get();

      List<TripModel> matches = [];
      for (var doc in matchingSnapshot.docs) {
        if (doc.id != tripId) {
          // Don't include current user
          try {
            final data = doc.data();
            final matchTrip = TripModel(
              id: data['id'] ?? doc.id,
              name: data['name'] ?? 'Unknown',
              profileImage:
                  data['profileImage'] ?? 'assets/default_profile.png',
              description: data['description'] ?? '',
              budget: data['budget'] ?? 0,
              startDate:
                  (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
              endDate:
                  (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
              state: data['state'] ?? 'Unknown',
              district: data['district'] ?? 'Unknown',
              village: data['village'] ?? 'Unknown',
              personalityType: data['personalityType'] ?? 'Adventure',
              age: data['age'] ?? 0,
              gender: data['gender'] ?? 'Other',
              imagePaths: List<String>.from(data['imagePaths'] ?? []),
            );

            // Check if matches budget and dates
            if (newTrip.isMatchWith(matchTrip)) {
              matches.add(matchTrip);
            }
          } catch (e) {
            debugPrint('Error processing match: $e');
          }
        }
      }

      if (!mounted) return;

      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No matching profiles found. Check back later!'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to SwipeCardScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  SwipeCardScreen(initialTrips: matches, currentUser: newTrip),
        ),
      );
    } catch (e) {
      debugPrint('Error submitting trip: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Age and Gender
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) => value!.isEmpty ? 'Age required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          ['Male', 'Female', 'Other']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => selectedGender = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'About Your Trip',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Description required' : null,
              ),
              const SizedBox(height: 16),

              // State Dropdown
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(
                  labelText: 'Select State',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                items:
                    stateDistricts.keys
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ),
                        )
                        .toList(),
                onChanged: _onStateChanged,
              ),
              const SizedBox(height: 16),

              // District Dropdown
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'Select District',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                items:
                    (stateDistricts[selectedState] ?? [])
                        .map(
                          (district) => DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          ),
                        )
                        .toList(),
                onChanged: _onDistrictChanged,
              ),
              const SizedBox(height: 16),

              // Village Dropdown
              DropdownButtonFormField<String>(
                value: selectedVillage,
                decoration: const InputDecoration(
                  labelText: 'Select Village/City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                items:
                    (districtVillages[selectedDistrict]?.keys.toList() ?? [])
                        .map(
                          (village) => DropdownMenuItem(
                            value: village,
                            child: Text(village),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedVillage = value),
              ),
              const SizedBox(height: 16),

              // Budget
              TextFormField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Budget required' : null,
              ),
              const SizedBox(height: 16),

              // Personality Type
              DropdownButtonFormField<String>(
                value: selectedPersonality,
                decoration: const InputDecoration(
                  labelText: 'Personality Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_people),
                ),
                items:
                    personalityTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => selectedPersonality = value),
              ),
              const SizedBox(height: 16),

              // Date Pickers
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickDate(true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _startDate == null
                            ? 'Start Date'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _startDate != null
                                ? Colors.purple
                                : Colors.grey[300],
                        foregroundColor:
                            _startDate != null
                                ? Colors.white
                                : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // End Date
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickDate(false),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _endDate == null
                            ? 'End Date'
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _endDate != null ? Colors.purple : Colors.grey[300],
                        foregroundColor:
                            _endDate != null ? Colors.white : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile Image Upload
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.purple.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      if (selectedImages.isEmpty)
                        Column(
                          children: [
                            const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.purple,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to upload photos',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to add more photos',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF967BB6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text(
                            'Find Matches',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    budgetController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
