import 'package:equatable/equatable.dart';

class AdsState extends Equatable {
  /// Whether consent allows requesting ads at all.
  final bool canRequestAds;

  /// Whether Settings must offer a way to change the consent choice.
  final bool privacyOptionsRequired;

  /// Training is showing flashcards, where swipes and buttons would risk
  /// accidental banner taps.
  final bool trainingSessionActive;

  /// A quiz or listening test is open, where answer buttons sit near the
  /// bottom.
  final bool quizSectionOpen;

  const AdsState({
    this.canRequestAds = false,
    this.privacyOptionsRequired = false,
    this.trainingSessionActive = false,
    this.quizSectionOpen = false,
  });

  AdsState copyWith({
    bool? canRequestAds,
    bool? privacyOptionsRequired,
    bool? trainingSessionActive,
    bool? quizSectionOpen,
  }) => AdsState(
    canRequestAds: canRequestAds ?? this.canRequestAds,
    privacyOptionsRequired:
        privacyOptionsRequired ?? this.privacyOptionsRequired,
    trainingSessionActive: trainingSessionActive ?? this.trainingSessionActive,
    quizSectionOpen: quizSectionOpen ?? this.quizSectionOpen,
  );

  @override
  List<Object?> get props => <Object?>[
    canRequestAds,
    privacyOptionsRequired,
    trainingSessionActive,
    quizSectionOpen,
  ];
}
