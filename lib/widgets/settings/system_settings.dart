part of 'package:maid/main.dart';

class SystemSettings extends StatelessWidget {
  final AppSettings settings;
  
  const SystemSettings({
    super.key, 
    required this.settings
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        AppLocalizations.of(context)!.systemSettings,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ListenableTextField<AppSettings>(
        listenable: settings,
        selector: () => settings.systemPrompt,
        onChanged: settings.setSystemPrompt,
        labelText: AppLocalizations.of(context)!.systemPrompt,
        keyboardType: TextInputType.multiline,
        maxLines: null
      ),
      const SizedBox(height: 8),
      LocaleDropdown(settings: settings),
      const SizedBox(height: 8),
      ThemeModeDropdown(settings: settings),
      const SizedBox(height: 8),
      Text(
        AppLocalizations.of(context)!.themeSeedColor,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 4),
      buildColorPicker(),
    ],
  );

  Widget buildColorPicker() => ListenableBuilder(
    listenable: settings,
    builder: (context, child) => HueRingPicker(
      portraitOnly: true,
      displayThumbColor: false,
      pickerColor: settings.seedColor, 
      onColorChanged: (newColor) => settings.seedColor = newColor,
    ),
  );
}