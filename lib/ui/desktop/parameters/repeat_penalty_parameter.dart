import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class RepeatPenaltyParameter extends StatelessWidget {
  const RepeatPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) { 
        return SliderGridTile(
          labelText: 'Repeat Penalty',
          inputValue: session.model.penaltyRepeat,
          sliderMin: 0.0,
          sliderMax: 2.0,
          sliderDivisions: 200,
          onValueChanged: (value) {
            session.model.penaltyRepeat = value;
            session.notify();
          }
        );
      }
    );
  }
}
