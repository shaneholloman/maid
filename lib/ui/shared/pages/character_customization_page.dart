import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/desktop_navigator.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:maid/ui/shared/dialogs/storage_operation_dialog.dart';
import 'package:maid/ui/shared/utilities/session_busy_overlay.dart';
import 'package:maid/ui/shared/tiles/text_field_list_tile.dart';
import 'package:maid/ui/shared/utilities/future_tile_image.dart';
import 'package:provider/provider.dart';

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  State<CharacterCustomizationPage> createState() =>
      _CharacterCustomizationPageState();
}

class _CharacterCustomizationPageState extends State<CharacterCustomizationPage> {
  bool regenerate = true;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController personalityController;
  late TextEditingController scenarioController;
  late TextEditingController systemController;
  late List<TextEditingController> greetingControllers;
  late List<TextEditingController> exampleControllers;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
    personalityController.dispose();
    scenarioController.dispose();
    systemController.dispose();
    
    for (var controller in greetingControllers) {
      controller.dispose();
    }
    for (var controller in exampleControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (AppPreferences.of(context).isDesktop) {
              DesktopNavigator.of(context).navigateSidePanel('/characters');
            } 
            else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          "Character Customization"
        ),
      ),
      body: Consumer<Character>(
        builder: buildBody,
      )
    );
  }

  Widget buildBody(BuildContext context, Character character, Widget? child) {
    if (regenerate) {
      nameController = TextEditingController(text: character.name);
      descriptionController = TextEditingController(text: character.description);
      personalityController = TextEditingController(text: character.personality);
      scenarioController = TextEditingController(text: character.scenario);
      systemController = TextEditingController(text: character.system);

      greetingControllers = List.generate(
        character.greetings.length,
        (index) => TextEditingController(text: character.greetings[index]),
      );

      exampleControllers = List.generate(
        character.examples.length,
        (index) =>
            TextEditingController(text: character.examples[index]["content"]),
      );

      regenerate = false;
    }

    return customColumn([
      const SizedBox(height: 10.0),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureTileImage(
          key: character.key,
          image: character.profile,
          borderRadius: BorderRadius.circular(10.0),
        )
      ),
      const SizedBox(height: 20.0),
      Text(
        character.name,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 20.0),
      buttonGridView(character),
      const SizedBox(height: 20.0),
      Divider(
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      TextFieldListTile(
        headingText: 'Name',
        labelText: 'Name',
        controller: nameController,
        onChanged: (value) {
          character.name = value;
        },
        multiline: false,
      ),
      Divider(
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      SwitchListTile(
        title: const Text('Use System'),
        value: character.useSystem,
        onChanged: (value) {
          character.useSystem = value;
        },
      ),
      if (character.useSystem) ...system(character),
      Divider(
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      SwitchListTile(
        title: const Text('Use Greeting'),
        value: character.useGreeting,
        onChanged: (value) {
          character.useGreeting = value;
        },
      ),
      if (character.useGreeting) ...greetings(character),
      Divider(
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).colorScheme.primary,
      ),
      SwitchListTile(
        title: const Text('Use Examples'),
        value: character.useExamples,
        onChanged: (value) {
          character.useExamples = value;
        },
      ),
      if (character.useExamples) ...examples(character),
    ]);
  }

  Widget customColumn(List<Widget> children) {
    return SessionBusyOverlay(
      child: SingleChildScrollView(
        child: Column(
          children: children
        )
      )
    );
  }

  Widget buttonGridView(Character character) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        FilledButton(
          onPressed: () {
            regenerate = true;
            character.reset();
          },
          child: const Text(
            "Reset All",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            showDialog(
              context: context,
              builder: (context) => StorageOperationDialog(future: character.importImage())
            );
          },
          child: const Text(
            "Load Image",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => StorageOperationDialog(future: character.exportImage())
          ),
          child: const Text(
            "Save Image",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => StorageOperationDialog(future: character.exportSTV2())
          ),
          child: const Text(
            "Save STV2 JSON",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => StorageOperationDialog(future: character.exportMCF())
          ),
          child: const Text(
            "Save MCF JSON",
            softWrap: false
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            showDialog(
              context: context,
              builder: (context) => StorageOperationDialog(future: character.importJSON())
            );
          },
          child: const Text(
            "Load JSON",
            softWrap: false
          ),
        ),
      ],
    );
  }

  List<Widget> greetings(Character character) {
    List<Widget> widgets = [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          FilledButton(
            onPressed: () {
              regenerate = true;
              character.newGreeting();
            },
            child: const Text(
              "Add Greeting"
            ),
          ),
          FilledButton(
            onPressed: () {
              regenerate = true;
              character.removeLastGreeting();
            },
            child: const Text(
              "Remove Greeting"
            ),
          )
        ]
      ),
    ];

    if (character.greetings.isNotEmpty) {
      for (int i = 0; i < character.greetings.length; i++) {
        widgets.add(
          TextFieldListTile(
            headingText: 'Greeting $i',
            labelText: 'Greeting $i',
            controller: greetingControllers[i],
            onChanged: (value) {
              character.updateGreeting(i, value);
            },
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> examples(Character character) {
    List<Widget> widgets = [
      examplesButtonsWrap()
    ];

    if (character.examples.isNotEmpty) {
      for (int i = 0; i < character.examples.length; i++) {
        widgets.add(
          TextFieldListTile(
            headingText:'${Utilities.capitalizeFirst(character.examples[i]["role"])} Content',
            labelText: character.examples[i]["role"],
            controller: exampleControllers[i],
            onChanged: (value) {
              character.updateExample(i, value);
            },
          ),
        );
      }
    }

    return widgets;
  }

  Widget examplesButtonsWrap() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        FilledButton(
          onPressed: () {
            regenerate = true;
            Character.of(context).newExample(true);
          },
          child: const Text(
            "Add Prompt",
            overflow: TextOverflow.ellipsis
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            Character.of(context).newExample(false);
          },
          child: const Text(
            "Add Response",
            overflow: TextOverflow.ellipsis
          ),
        ),
        FilledButton(
          onPressed: () {
            regenerate = true;
            Character.of(context).newExample(null);
          },
          child: const Text(
            "Add System",
            overflow: TextOverflow.ellipsis
          ),
        ),
        FilledButton(
          onPressed: () {
            if (exampleControllers.length >= 2) {
              regenerate = true;
              Character.of(context).removeLastExample();
            }
          },
          child: const Text(
            "Remove Last",
            overflow: TextOverflow.ellipsis
          ),
        )
      ]
    );
  }

  List<Widget> system(Character character) {
    return [
      TextFieldListTile(
        headingText: 'Description',
        labelText: 'Description',
        controller: descriptionController,
        onChanged: (value) {
          character.description = value;
        },
        multiline: true,
      ),
      TextFieldListTile(
        headingText: 'Personality',
        labelText: 'Personality',
        controller: personalityController,
        onChanged: (value) {
          character.personality = value;
        },
        multiline: true,
      ),
      TextFieldListTile(
        headingText: 'Scenario',
        labelText: 'Scenario',
        controller: scenarioController,
        onChanged: (value) {
          character.scenario = value;
        },
        multiline: true,
      ),
      TextFieldListTile(
        headingText: 'System Prompt',
        labelText: 'System Prompt',
        controller: systemController,
        onChanged: (value) {
          character.system = value;
        },
        multiline: true,
      ),
    ];
  }
}
