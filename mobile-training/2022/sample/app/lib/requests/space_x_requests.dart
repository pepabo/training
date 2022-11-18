import 'package:graphql/client.dart';
import 'package:app/models/ship.dart';

class SpaceXRequests {
  final Link _link = HttpLink("https://api.spacex.land/graphql/");
  late final GraphQLClient client;

  SpaceXRequests() {
    client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<Ship> fetchShip({required String id}) async {
    final QueryOptions options = QueryOptions(
      document: gql(
        r'''
          query Ship($id: ID!){
            ship(id:$id){
              id
              image
            }
          }
        ''',
      ),
      variables: {
        'id': '$id',
      },
    );

    final QueryResult response = await client.query(options);

    final result = response.data;
    final shipResult = result?['ship'];
    final ship = Ship.fromJson(shipResult);

    return ship;
  }
}
