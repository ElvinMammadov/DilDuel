/// The training levels, in display order.
const List<String> trainingLevels = <String>[
  'A1',
  'A2',
  'B1',
  'B2',
  'C1',
  'C2',
];

/// Everyday topics, in display order. Each name is also the key of the topic's
/// word ids in `assets/training_topics.json`.
const List<String> trainingTopics = <String>[
  'food_drink',
  'family_relationships',
  'animals',
  'plants_nature',
  'body_health',
  'clothes',
  'house_home',
  'travel_transport',
  'time_weather',
  'numbers_quantities',
  'shopping_money',
];

/// Prefix that tells a topic deck apart from a CEFR level in saved progress.
const String topicDeckPrefix = 'topic_';

/// Returns the deck key under which progress for [topic] is stored.
String topicDeck(String topic) => '$topicDeckPrefix$topic';

/// Whether [deck] is a topic deck rather than a CEFR level.
bool isTopicDeck(String deck) => deck.startsWith(topicDeckPrefix);

/// Returns the topic name for a topic [deck] key.
String topicOfDeck(String deck) => deck.substring(topicDeckPrefix.length);

/// Every trainable deck: the CEFR levels followed by the topics.
final List<String> trainingDecks = <String>[
  ...trainingLevels,
  ...trainingTopics.map(topicDeck),
];

/// Contract for persisting per-deck (level or topic) training progress.
abstract class TrainingProgressRepository {
  /// Returns the saved word index for [level], or 0 if never set.
  Future<int> getLevelPosition(String level);

  /// Persists [index] for [level].
  Future<void> saveLevelPosition(String level, int index);

  /// Returns the most recently accessed level, or `null` if none.
  Future<String?> getLastTrainingLevel();

  /// Sends any positions still waiting to be synced to remote storage.
  /// A no-op for repositories that write through immediately.
  Future<void> flush();
}
