import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) { 
        return SwitchListTile(
          title: const Text('Penalize New Line'),
          value: session.model.penalizeNewline,
          onChanged: (value) {
            session.model.penalizeNewline = value;
            session.notify();
          },
        );
      }
    );
  }
}
