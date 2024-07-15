import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class TypicalPParameter extends StatelessWidget {
  const TypicalPParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderGridTile(
          labelText: 'TypicalP',
          inputValue: session.model.typicalP,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.typicalP = value;
            session.notify();
          }
        );
      }
    );
  }
}
