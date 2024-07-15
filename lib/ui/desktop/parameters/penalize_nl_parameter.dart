import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/switch_container.dart';
import 'package:provider/provider.dart';

class PenalizeNlParameter extends StatelessWidget {
  const PenalizeNlParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: buildSwitchContainer
    );
  }

  Widget buildSwitchContainer(BuildContext context, Session session, Widget? child) {  
    return SwitchContainer(
      title: 'Penalize New Line',
      initialValue: session.model.penalizeNewline,
      onChanged: (value) {
        session.model.penalizeNewline = value;
        session.notify();
      },
    );
  }
}
