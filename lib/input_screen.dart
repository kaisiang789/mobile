import 'package:flutter/material.dart';
import 'image_generation_service.dart';
import 'poster_screen.dart';
import '../diagnostic.dart';
import 'package:firebase_ai/firebase_ai.dart'; 

class InputScreen extends StatefulWidget {
  const InputScreen({super.key, required this.title});

  final String title;

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();
  final TextEditingController themeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  void generatePoster(String prompt) async {
    final image = await ImageGenerationService.generateImage(prompt);

    if (mounted) {
      Navigator.pop(context); 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PosterScreen(image: image)),
      );
    }
  }

  Future<void> _handleViewSuggestion() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash', 
        generationConfig: GenerationConfig(temperature: 0.7),
      );

      final prompt = """
      You are an expert event planner. Based on the following info, generate a plan in JSON format.
      Theme: ${themeController.text}
      Duration: ${timeController.text} hours
      Budget: RM ${budgetController.text}
      Participants: ${peopleController.text}
      Location: ${locationController.text}

      The output must be a valid JSON object with exactly these keys:
      "event_title", "description", "schedule", "tasks", "items_needed".
      "schedule", "tasks", and "items_needed" must be lists of strings.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      

      String? jsonText = response.text?.replaceAll('```json', '').replaceAll('```', '').trim();

      if (mounted) {
        Navigator.pop(context);
        if (jsonText != null && jsonText.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventSuggestionScreen(suggestionJson: jsonText),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("发生错误: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.grey,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTextField(timeController, 'Event Duration(hour)', Icons.access_time),
              const SizedBox(height: 16),
              _buildTextField(budgetController, 'Event Budget(RM)', Icons.attach_money),
              const SizedBox(height: 16),
              _buildTextField(peopleController, 'Expected Numbers of Participants', Icons.people),
              const SizedBox(height: 16),
              _buildTextField(themeController, 'Event Theme', Icons.title),
              const SizedBox(height: 16),
              _buildTextField(locationController, 'Event Location', Icons.map_outlined),
              
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                  color: Colors.grey[800],
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    String theme = themeController.text.isNotEmpty ? themeController.text : "Theme";
                    String prompt = "A realistic event poster of a $theme.";
                    generatePoster(prompt);
                  },
                  child: const Text('GENERATE POSTER', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                  color: Colors.indigo, 
                  onPressed: _handleViewSuggestion,
                  child: const Text(
                    'VIEW SUGGESTION',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}