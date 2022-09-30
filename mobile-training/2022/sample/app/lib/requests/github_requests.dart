import 'package:graphql/client.dart';

class GithubRequests{
  late final Link _link;
  late final GraphQLClient _client;
  final String accessToken;

  GithubRequests(
    this.accessToken
  ){
    _link = HttpLink('https://api.github.com/graphql', defaultHeaders: {
      'Authorization' : 'bearer $accessToken'
    });
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<void> fetch() async {
    final QueryOptions options = QueryOptions(
      document: gql(
        r'''
          query Login() {
            viewer {
              login
              avatarUrl
            }
          }
        ''',
      ),
    );

    final QueryResult response = await _client.query(options);

    final result = response.data;
    print(result);
  }
}