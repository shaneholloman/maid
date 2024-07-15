import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/ui/desktop/side_panels/model_settings/google_gemini_panel.dart';
import 'package:maid/ui/desktop/side_panels/model_settings/llama_cpp_panel.dart';
import 'package:maid/ui/desktop/side_panels/model_settings/mistral_ai_panel.dart';
import 'package:maid/ui/desktop/side_panels/model_settings/ollama_panel.dart';
import 'package:maid/ui/desktop/side_panels/model_settings/open_ai_panel.dart';
import 'package:provider/provider.dart';

class ModelSettingsPanel extends StatelessWidget {
  const ModelSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        switch (session.model.type) {
          case LargeLanguageModelType.llamacpp:
            return const LlamaCppPanel();
          case LargeLanguageModelType.ollama:
            return const OllamaPanel();
          case LargeLanguageModelType.openAI:
            return const OpenAiPanel();
          case LargeLanguageModelType.mistralAI:
            return const MistralAiPanel();
          case LargeLanguageModelType.gemini:
            return const GoogleGeminiPanel();
          default:
            throw Exception('Invalid model type');
        }
      }
    );
  }
}