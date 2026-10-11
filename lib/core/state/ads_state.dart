import 'package:equatable/equatable.dart';

class AdsState extends Equatable {
  /// Whether consent allows requesting ads at all.
  final bool canRequestAds;

  /// Whether Settings must offer a way to change the consent choice.
  final bool privacyOptionsRequired;

  /// Training is showing flashcards rather than the level cards.
  final bool trainingSessionActive;

  /// A quiz, listening test or results list is open rather than the card list.
  final bool quizSectionOpen;

  /// A bookmarks or unknown-words list is open rather than the card list.
  final bool bookmarksSectionOpen;

  const AdsState({
    this.canRequestAds = false,
    this.privacyOptionsRequired = false,
    this.trainingSessionActive = false,
    this.quizSectionOpen = false,
    this.bookmarksSectionOpen = false,
  });

  AdsState copyWith({
    bool? canRequestAds,
    bool? privacyOptionsRequired,
    bool? trainingSessionActive,
    bool? quizSectionOpen,
    bool? bookmarksSectionOpen,
  }) => AdsState(
    canRequestAds: canRequestAds ?? this.canRequestAds,
    privacyOptionsRequired:
        privacyOptionsRequired ?? this.privacyOptionsRequired,
    trainingSessionActive: trainingSessionActive ?? this.trainingSessionActive,
    quizSectionOpen: quizSectionOpen ?? this.quizSectionOpen,
    bookmarksSectionOpen: bookmarksSectionOpen ?? this.bookmarksSectionOpen,
  );

  @override
  List<Object?> get props => <Object?>[
    canRequestAds,
    privacyOptionsRequired,
    trainingSessionActive,
    quizSectionOpen,
    bookmarksSectionOpen,
  ];
}
