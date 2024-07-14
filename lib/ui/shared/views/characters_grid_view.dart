import 'package:flutter/material.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/ui/shared/tiles/character_tile.dart';
import 'package:provider/provider.dart';

class CharactersGridView extends StatelessWidget {

  const CharactersGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Character>(
      builder: buildGridView
    );
  }

  Widget buildGridView(BuildContext context, Character character, Widget? child) {
    Character.save();

    return GridView.builder(
      itemCount: Character.characters.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75
      ),
      itemBuilder: buildCharacterTile, 
    );
  }

  Widget buildCharacterTile(BuildContext context, int index) {
    return CharacterTile(
      character: Character.characters[index],
      isSelected: Character.of(context) == Character.characters[index],
    );
  }
}