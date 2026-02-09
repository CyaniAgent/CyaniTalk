import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cyanitalk/src/features/misskey/data/misskey_repository.dart';
import 'package:cyanitalk/src/core/api/misskey_api.dart';
import 'package:cyanitalk/src/features/misskey/domain/note.dart';
import 'package:cyanitalk/src/features/misskey/domain/misskey_user.dart';

import 'package:cyanitalk/src/core/utils/logger.dart';

class MockMisskeyApi extends Mock implements MisskeyApi {}

void main() {
  setUpAll(() {
    logger.setupForTesting();
  });

  late MisskeyRepository repository;
  late MockMisskeyApi mockApi;

  setUp(() {
    mockApi = MockMisskeyApi();
    repository = MisskeyRepository(mockApi);
  });

  group('MisskeyRepository', () {
    test('getMe returns a MisskeyUser when API call is successful', () async {
      // Arrange
      final userData = {
        'id': 'user123',
        'username': 'miku01',
        'name': 'Hatsune Miku',
        'avatarUrl': 'https://example.com/miku.png',
      };
      when(() => mockApi.i()).thenAnswer((_) async => userData);

      // Act
      final result = await repository.getMe();

      // Assert
      expect(result, isA<MisskeyUser>());
      expect(result.id, 'user123');
      expect(result.username, 'miku01');
      verify(() => mockApi.i()).called(1);
    });

    test('getMe rethrows exception when API call fails', () async {
      // Arrange
      when(() => mockApi.i()).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(() => repository.getMe(), throwsException);
      verify(() => mockApi.i()).called(1);
    });

    test('getTimeline returns list of notes when successful', () async {
      // Arrange
      final timelineData = [
        {
          'id': 'note1',
          'text': 'Hello Miku!',
          'createdAt': '2024-01-01T00:00:00.000Z',
        },
        {
          'id': 'note2',
          'text': 'World is mine',
          'createdAt': '2024-01-01T00:01:00.000Z',
        },
      ];
      when(
        () => mockApi.getTimeline('Home', limit: 20),
      ).thenAnswer((_) async => timelineData);

      // Act
      final result = await repository.getTimeline('Home');

      // Assert
      expect(result, isA<List<Note>>());
      expect(result.length, 2);
      expect(result[0].id, 'note1');
      verify(() => mockApi.getTimeline('Home', limit: 20)).called(1);
    });

    test('createNote calls API with correct parameters', () async {
      // Arrange
      when(
        () => mockApi.createNote(
          text: 'Miku Miku Ni Shite Ageru',
          visibility: 'public',
        ),
      ).thenAnswer((_) async => {});

      // Act
      await repository.createNote(
        text: 'Miku Miku Ni Shite Ageru',
        visibility: 'public',
      );

      // Assert
      verify(
        () => mockApi.createNote(
          text: 'Miku Miku Ni Shite Ageru',
          visibility: 'public',
        ),
      ).called(1);
    });

    test('addReaction calls API correctly', () async {
      // Arrange
      when(
        () => mockApi.createReaction('note123', '❤️'),
      ).thenAnswer((_) async => {});

      // Act
      await repository.addReaction('note123', '❤️');

      // Assert
      verify(() => mockApi.createReaction('note123', '❤️')).called(1);
    });
  });
}
