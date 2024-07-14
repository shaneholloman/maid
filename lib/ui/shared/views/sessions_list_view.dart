import 'package:flutter/material.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/ui/shared/tiles/session_tile.dart';
import 'package:provider/provider.dart';

class SessionsListView extends StatelessWidget {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (c, s, ch) => buildListView(),
    );
  }

  Widget buildListView() {
    Session.save();

    return ListView.builder(
      itemCount: Session.sessions.length, 
      itemBuilder: buildSessionTile
    );
  }

  Widget buildSessionTile(BuildContext context, int index) {
    return SessionTile(
      session: Session.sessions[index]
    );
  }
}