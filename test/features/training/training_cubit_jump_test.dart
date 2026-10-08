import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProgressRepository implements TrainingProgressRepository {
  final List<(String, int)> saved = <(String, int)>[];

  @override
  Future<int> getLevelPosition(String level) async => 0;

  @override
  Future<void> saveLevelPosition(String level, int index) async =>
      saved.add((level, index));

  @override
  Future<String?> getLastTrainingLevel() async => null;

  @override
  Future<void> flush() async {}
}

/// Exposes [emit] so tests can start from a known state without a database.
class _TestTrainingCubit extends TrainingCubit {
  _TestTrainingCubit(super.repository);

  void seed(TrainingState state) => emit(state);
}

void main() {
  late _FakeProgressRepository repository;
  late _TestTrainingCubit cubit;

  TrainingReady readyAt(int index, {int total = 10}) => TrainingReady(
        words: List<Word>.generate(
          total,
          (int i) => Word(key: 'word$i'),
        ),
        currentIndex: index,
        level: 'A1',
      );

  setUp(() {
    repository = _FakeProgressRepository();
    cubit = _TestTrainingCubit(repository);
  });

  tearDown(() => cubit.close());

  group('jumpTo', () {
    test('moves to the index and persists it once', () async {
      cubit.seed(readyAt(0));

      await cubit.jumpTo(7);

      check((cubit.state as TrainingReady).currentIndex).equals(7);
      check(repository.saved).deepEquals(<(String, int)>[('A1', 7)]);
      check(cubit.savedIndices['A1']).equals(7);
    });

    test('clamps an index past the end to the last word', () async {
      cubit.seed(readyAt(0));

      await cubit.jumpTo(99);

      check((cubit.state as TrainingReady).currentIndex).equals(9);
    });

    test('clamps a negative index to the first word', () async {
      cubit.seed(readyAt(5));

      await cubit.jumpTo(-3);

      check((cubit.state as TrainingReady).currentIndex).equals(0);
    });

    test('does nothing when already on that word', () async {
      cubit.seed(readyAt(4));

      await cubit.jumpTo(4);

      check(repository.saved).isEmpty();
    });

    test('is ignored while no level is loaded', () async {
      await cubit.jumpTo(3);

      check(cubit.state).isA<TrainingInitial>();
      check(repository.saved).isEmpty();
    });
  });
}
