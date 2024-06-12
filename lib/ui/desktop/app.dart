import 'package:flutter/material.dart';
import 'package:maid/mocks/mock_llama_cpp_page.dart';
import 'package:maid/providers/app_preferences.dart';
import 'package:maid/providers/desktop_layout.dart';
import 'package:maid/static/themes.dart';
import 'package:maid/ui/desktop/pages/home_page.dart';
import 'package:maid/ui/mobile/pages/about_page.dart';
import 'package:maid/ui/mobile/pages/character/character_browser_page.dart';
import 'package:maid/ui/mobile/pages/character/character_customization_page.dart';
import 'package:maid/ui/mobile/pages/platforms/gemini_page.dart';
import 'package:maid/ui/mobile/pages/platforms/mistralai_page.dart';
import 'package:maid/ui/mobile/pages/platforms/ollama_page.dart';
import 'package:maid/ui/mobile/pages/platforms/openai_page.dart';
import 'package:maid/ui/mobile/pages/settings_page.dart';
import 'package:provider/provider.dart';

class DesktopApp extends StatelessWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Maid',
          theme: Themes.lightTheme(),
          darkTheme: Themes.darkTheme(),
          themeMode: appPreferences.themeMode,
          initialRoute: '/',
          routes: {
            '/character': (context) => const CharacterCustomizationPage(),
            '/characters': (context) => const CharacterBrowserPage(),
            '/llamacpp': (context) => const LlamaCppPage(),
            '/ollama': (context) => const OllamaPage(),
            '/openai': (context) => const OpenAiPage(),
            '/mistralai': (context) => const MistralAiPage(),
            '/gemini': (context) => const GoogleGeminiPage(),
            '/settings': (context) => const SettingsPage(),
            '/about': (context) => const AboutPage(),
          },
          home: ChangeNotifierProvider(
            create: (context) => DesktopLayout(),
            child: const DesktopHomePage()
          )
        );
      },
    );
  }
}