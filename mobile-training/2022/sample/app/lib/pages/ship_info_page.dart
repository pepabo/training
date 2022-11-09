import 'package:app/models/ship.dart';
import 'package:app/requests/space_x_requests.dart';
import 'package:flutter/material.dart';

class ShipInfoPage extends StatefulWidget {
  const ShipInfoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShipInfoPageState();
}

class _ShipInfoPageState extends State {
  Ship? ship;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final image = ship?.image;
    return Scaffold(
      appBar: AppBar(title: const Text("InfoPage")),
      body: Column(
        children: [
          if (image != null) Image.network(image),
          TextButton(
              onPressed: () async {
                final ship = await SpaceXRequests().fetchShip(id: "GOMSTREE");

                setState(() {
                  this.ship = ship;
                });
              },
              child: const Text("リクエスト")),
        ],
      ),
    );
  }
}
