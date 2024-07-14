import 'package:flutter/material.dart';
import 'package:maid/classes/providers/character.dart';

class NewCharacterButton extends StatelessWidget {
  const NewCharacterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Character.characters.add(Character());
      },
      child: const Text(
        "New Character"
      ),
    );
  }
}