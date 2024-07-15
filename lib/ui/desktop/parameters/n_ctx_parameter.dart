import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/slider_grid_tile.dart';
import 'package:provider/provider.dart';

class NCtxParameter extends StatelessWidget {
  const NCtxParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) { 
        return SliderGridTile(
          labelText: 'NCtx',
          inputValue: session.model.nCtx,
          sliderMin: 0.0,
          sliderMax: 4096.0,
          sliderDivisions: 4095,
          onValueChanged: (value) {
            session.model.nCtx = value.round();
            session.notify();
          }
        );
      }
    );
  }
}
