import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/enumerators/chat_role.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:maid/ui/shared/chat_widgets/chat_field.dart';
import 'package:maid/ui/shared/chat_widgets/chat_message.dart';
import 'package:provider/provider.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildChat(),
        ),
        const ChatField(),
      ],
    );
  }

  List<ChatMessageWidget> _getChatWidgets(List<ChatNode> chat) {
    List<ChatMessageWidget> chatWidgets = [];

    for (final message in chat) {
      chatWidgets.add(ChatMessageWidget(hash: message.hash));
    }

    return chatWidgets;
  }

  Widget _buildChat() {
    return Consumer3<Session, Character, User>(
      builder: (context, session, character, user, child) {
        List<ChatNode> chat = session.chat.getChat();

        if (
          chat.isEmpty && 
          character.useGreeting && 
          character.greetings.isNotEmpty
        ) {
          final index = Random().nextInt(character.greetings.length);

          if (character.greetings[index].isNotEmpty) {
            final message = ChatNode(
              role: ChatRole.assistant,
              content: Utilities.formatPlaceholders(character.greetings[index], user.name, character.name),
              finalised: true
            );

            session.chat.addNode(message);
            chat = [message];
          }
        }

        final chatWidgets = _getChatWidgets(chat);

        return Builder(
          builder: (BuildContext context) => GestureDetector(
            onHorizontalDragEnd: (details) {
              // Check if the drag is towards right with a certain velocity
              if (details.primaryVelocity! > 100) {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              }
            },
            child: ListView.builder(
              itemCount: chatWidgets.length,
              itemBuilder: (BuildContext context, int index) {
                return chatWidgets[index];
              },
            )
          ),
        );
      },
    );
  }
}