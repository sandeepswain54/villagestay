import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _defaultModel = 'llama-3.1-8b-instant'; // Groq model names
  
  // ⚠️ REPLACE WITH YOUR GROQ API KEY (from https://console.groq.com/)
  static const String _apiKey = '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';

  Future<String> generateResponse(String prompt) async {
    try {
      

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant for Village Stay, a village tourism service. '
                         'Welcome users warmly to Village Stay and provide helpful information about '
                         'village stays, local experiences, cultural activities, accommodation, '
                         'and tourism services. Be friendly, informative, and professional. '
                         'Always start by welcoming users if they are new.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 15));

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseBody['choices'][0]['message']['content'].toString().trim();
      } else {
        // Provide detailed error information
        final errorMsg = responseBody['error']?['message'] ?? 'Unknown error';
        return 'I apologize, but I\'m having trouble connecting right now. '
               'Error: ${response.statusCode} - $errorMsg\n\n'
               'Please try again in a moment.';
      }
    } on TimeoutException {
      return 'The request is taking longer than expected. Please check your internet connection and try again.';
    } on http.ClientException catch (e) {
      return 'Network connection issue: ${e.message}. Please check your internet connection.';
    } catch (e) {
      // Fallback to smart responses if API fails
      return _getFallbackResponse(prompt);
    }
  }

  String _getFallbackResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('hello') || lowerPrompt.contains('hi') || lowerPrompt.contains('hey')) {
      return 'Hello! Welcome to Village Stay! 🌿 How can I help you with your village tourism experience today?';
    }
    else if (lowerPrompt.contains('price') || lowerPrompt.contains('cost') || lowerPrompt.contains('rate')) {
      return 'Our village stay packages start at ₹1500 per night and include accommodation, traditional meals, and guided cultural activities. Would you like more specific pricing details?';
    }
    else if (lowerPrompt.contains('booking') || lowerPrompt.contains('book') || lowerPrompt.contains('reserv')) {
      return 'You can book your village stay experience through our mobile app or website. We offer flexible booking options and 24/7 support!';
    }
    else if (lowerPrompt.contains('activity') || lowerPrompt.contains('do') || lowerPrompt.contains('experience')) {
      return 'We offer amazing activities like organic farming, traditional cooking classes, village walks, handicraft workshops, and cultural performances!';
    }
    else if (lowerPrompt.contains('accommodat') || lowerPrompt.contains('stay') || lowerPrompt.contains('room')) {
      return 'We provide comfortable traditional cottages with modern amenities, ensuring an authentic yet comfortable village experience.';
    }
    else if (lowerPrompt.contains('thank') || lowerPrompt.contains('thanks')) {
      return 'You\'re very welcome! 😊 I\'m here to help you plan an unforgettable village stay experience!';
    }
    else if (lowerPrompt.contains('contact') || lowerPrompt.contains('help') || lowerPrompt.contains('support')) {
      return 'You can reach our support team at support@villagestay.com or call +91-XXXXX-XXXXX. We\'re here 24/7 to assist you!';
    }
    else {
      return 'Thank you for your message! 🌿 At Village Stay, we specialize in authentic village tourism experiences with comfortable accommodation, delicious local cuisine, and immersive cultural activities. How can I help you plan your perfect village getaway?';
    }
  }

  // Test function to verify API key
  Future<void> testApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Groq API Test - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ Groq API key is VALID and working!');
      } else {
        print('❌ Groq API key issue. Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Groq API test error: $e');
    }
  }
}