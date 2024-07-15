import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class MirostatParameter extends StatelessWidget {
  const MirostatParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) { 
        return SliderGridTile(
          labelText: 'Mirostat',
          inputValue: session.model.mirostat,
          sliderMin: 0.0,
          sliderMax: 128.0,
          sliderDivisions: 127,
          onValueChanged: (value) {
            session.model.mirostat = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
