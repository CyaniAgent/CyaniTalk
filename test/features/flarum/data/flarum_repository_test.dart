import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cyanitalk/src/features/flarum/data/flarum_repository.dart';
import 'package:cyanitalk/src/core/api/flarum_api.dart';
import 'package:cyanitalk/src/features/flarum/data/models/discussion.dart';
import 'package:cyanitalk/src/core/utils/logger.dart';

class MockFlarumApi extends Mock implements FlarumApi {}

void main() {
  setUpAll(() {
    logger.setupForTesting();
  });

  late FlarumRepository repository;
  late MockFlarumApi mockApi;

  setUp(() {
    mockApi = MockFlarumApi();
    repository = FlarumRepository(mockApi);
  });

  group('FlarumRepository', () {
    test(
      'getDiscussions returns list of discussions when successful',
      () async {
        // Arrange
        final responseData = {
          'data': [
            {
              'type': 'discussions',
              'id': '1',
              'attributes': {'title': 'Miku Discussion', 'commentCount': 5},
            },
          ],
          'included': [],
        };
        when(
          () => mockApi.getDiscussions(
            limit: 20,
            offset: 0,
            include: 'user,lastPostedUser,tags',
          ),
        ).thenAnswer((_) async => responseData);

        // Act
        final result = await repository.getDiscussions(limit: 20, offset: 0);

        // Assert
        expect(result, isA<List<Discussion>>());
        expect(result.length, 1);
        expect(result[0].id, '1');
        expect(result[0].title, 'Miku Discussion');
        verify(
          () => mockApi.getDiscussions(
            limit: 20,
            offset: 0,
            include: 'user,lastPostedUser,tags',
          ),
        ).called(1);
      },
    );

    test(
      'searchDiscussions returns list of discussions matching query',
      () async {
        // Arrange
        final responseData = {
          'data': [
            {
              'type': 'discussions',
              'id': '2',
              'attributes': {'title': 'Searching for Miku', 'commentCount': 10},
            },
          ],
          'included': [],
        };
        when(
          () => mockApi.searchDiscussions('Miku'),
        ).thenAnswer((_) async => responseData);

        // Act
        final result = await repository.searchDiscussions('Miku');

        // Assert
        expect(result, isA<List<Discussion>>());
        expect(result.length, 1);
        expect(result[0].id, '2');
        verify(() => mockApi.searchDiscussions('Miku')).called(1);
      },
    );
  });
}
