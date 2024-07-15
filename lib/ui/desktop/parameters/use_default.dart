import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/switch_container.dart';
import 'package:provider/provider.dart';

class UseDefaultParameter extends StatelessWidget {
  const UseDefaultParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: buildSwitchContainer
    );
  }

  Widget buildSwitchContainer(BuildContext context, Session session, Widget? child) {  
    return SwitchContainer(
      title: 'Use Default Parameters',
      initialValue: session.model.useDefault,
      onChanged: (value) {
        session.model.useDefault = value;
        session.notify();
      },
    );
  }
}
