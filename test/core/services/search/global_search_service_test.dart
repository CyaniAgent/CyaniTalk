import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyanitalk/src/core/services/search/global_search_service.dart';
import 'package:cyanitalk/src/features/misskey/data/misskey_repository.dart';
import 'package:cyanitalk/src/features/misskey/data/misskey_repository_interface.dart';
import 'package:cyanitalk/src/features/flarum/application/flarum_providers.dart';
import 'package:cyanitalk/src/features/flarum/data/flarum_repository.dart';
import 'package:cyanitalk/src/features/misskey/domain/note.dart';
import 'package:cyanitalk/src/features/misskey/domain/misskey_user.dart';
import 'package:cyanitalk/src/features/flarum/data/models/discussion.dart';
import 'package:cyanitalk/src/core/utils/logger.dart';

class MockMisskeyRepository extends Mock implements IMisskeyRepository {}

class MockFlarumRepository extends Mock implements FlarumRepository {}

void main() {
  setUpAll(() {
    logger.setupForTesting();
  });

  late ProviderContainer container;
  late MockMisskeyRepository mockMisskeyRepo;
  late MockFlarumRepository mockFlarumRepo;

  setUp(() {
    mockMisskeyRepo = MockMisskeyRepository();
    mockFlarumRepo = MockFlarumRepository();

    // Default return values for mocks
    when(() => mockMisskeyRepo.host).thenReturn('misskey.io');

    container = ProviderContainer(
      overrides: [
        misskeyRepositoryProvider.overrideWithValue(
          AsyncValue.data(mockMisskeyRepo),
        ),
        flarumRepositoryProvider.overrideWithValue(mockFlarumRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GlobalSearch', () {
    test('search returns combined results from Misskey and Flarum', () async {
      // Arrange
      final mikuUser = MisskeyUser(id: '1', username: 'miku', name: 'Miku');
      final mikuNote = Note(
        id: '1',
        text: 'Miku Note',
        createdAt: DateTime.now(),
      );
      final mikuDiscussion = Discussion.fromJson({
        'id': '1',
        'attributes': {
          'title': 'Miku Discussion',
          'slug': 'miku-discussion',
          'commentCount': 5,
        },
      });

      when(
        () => mockMisskeyRepo.searchUsers('Miku', limit: 5),
      ).thenAnswer((_) async => [mikuUser]);
      when(
        () => mockMisskeyRepo.searchNotes('Miku', limit: 5),
      ).thenAnswer((_) async => [mikuNote]);
      when(
        () => mockFlarumRepo.searchDiscussions('Miku'),
      ).thenAnswer((_) async => [mikuDiscussion]);

      // Act
      final result = await container
          .read(globalSearchProvider.notifier)
          .search('Miku');

      // Assert
      expect(result, isNotEmpty);
      expect(
        result.any((r) => r.type == 'User' && r.source == 'misskey'),
        true,
      );
      expect(
        result.any((r) => r.type == 'Note' && r.source == 'misskey'),
        true,
      );
      expect(
        result.any((r) => r.type == 'Discussion' && r.source == 'flarum'),
        true,
      );

      verify(() => mockMisskeyRepo.searchUsers('Miku', limit: 5)).called(1);
      verify(() => mockMisskeyRepo.searchNotes('Miku', limit: 5)).called(1);
      verify(() => mockFlarumRepo.searchDiscussions('Miku')).called(1);
    });

    test('search handles empty query', () async {
      // Act
      final result = await container
          .read(globalSearchProvider.notifier)
          .search('');

      // Assert
      expect(result, isEmpty);
      verifyNever(() => mockMisskeyRepo.searchUsers(any()));
    });
  });
}
