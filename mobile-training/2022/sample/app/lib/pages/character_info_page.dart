import 'package:app/models/character.dart';
import 'package:app/requests/rick_requests.dart';
import 'package:flutter/material.dart';

class CharacterInfoPage extends StatefulWidget {
  const CharacterInfoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CharacterInfoPageState();
}

class _CharacterInfoPageState extends State {
  Character? character;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final characterImage = character?.image;
    return Scaffold(
      appBar: AppBar(title: const Text("CharacterInfoPage")),
      body: Column(
        children: [
          if (characterImage != null) Image.network(characterImage),
          TextButton(
            onPressed: () async {
              final character = await RickRequests().fetchCharacter(id: 4);
              setState(() {
                this.character = character;
              });
            },
            child: const Text("リクエスト")
          ),
        ],
      ),
    );
  }
}