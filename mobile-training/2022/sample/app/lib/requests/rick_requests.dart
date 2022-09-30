import 'package:graphql/client.dart';
import 'package:app/models/character.dart';

class RickRequests{
  final Link _link = HttpLink("https://rickandmortyapi.com/graphql");
  late final GraphQLClient client;

  RickRequests(){
    client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<Character> fetchCharacter({required int id}) async {
    final QueryOptions options = QueryOptions(
      document: gql(
        r'''
          query ReadCharacter($id: ID!) {
            character(id: $id) {
              name
              image
              status
              species
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
    final char = result?['character'];
    final character = Character.fromJson(char);

    return character;
  }
}