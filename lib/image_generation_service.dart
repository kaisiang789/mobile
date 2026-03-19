import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageGenerationService {
  static const apiKey = "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";

  static const apiUrl = "https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0";

  static Future<Uint8List> generateImage(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "width": 512,
          "height": 768,
          "num_inference_steps": 50,
          "guidance_scale": 7.5,
        },
        "options": {"wait_for_model": true},
      }),
    );

    if(response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      debugPrint(response.body);

      throw Exception("Failed to generate image: ${response.statusCode}");
    }
  }
}