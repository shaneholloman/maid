import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/huggingface_selection.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/ui/desktop/app.dart';
import 'package:maid/ui/mobile/app.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaidApp()
  );
}

class MaidApp extends StatelessWidget {
  const MaidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProviders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: snapshot.data!,
            child: buildConsumer(),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<List<ChangeNotifierProvider>> getProviders() async {
    return [
      ChangeNotifierProvider.value(value: await AppPreferences.last),
      ChangeNotifierProvider.value(value: await Session.last),
      ChangeNotifierProvider.value(value: await Character.last),
      ChangeNotifierProvider.value(value: await User.last),
      ChangeNotifierProvider.value(value: HuggingfaceSelection())
    ];
  }

  Widget buildConsumer() {
    return Consumer<AppPreferences>(
      builder: (context, appPreferences, child) {
        if (appPreferences.isDesktop) { 
          return const DesktopApp();
        } 
        else {
          return const MobileApp();
        }
      },
    );
  }
}
