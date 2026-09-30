library listening;

import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/components/app_card.dart';
import 'package:flutter_dic/core/components/buttons/app_elevated_button.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/models/answer_record.dart';
import 'package:flutter_dic/core/data/repositories/listening_result_repository.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

part 'domain/entities/listening_question.dart';
part 'presentation/bloc/listening_state.dart';
part 'presentation/bloc/listening_cubit.dart';
part 'presentation/widgets/listening_question_card.dart';
part 'presentation/widgets/listening_in_progress_view.dart';
part 'presentation/widgets/listening_result_view.dart';
part 'presentation/widgets/listening_initial_view.dart';
part 'presentation/screens/listening_screen.dart';
