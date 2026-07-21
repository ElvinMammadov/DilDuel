library quiz;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/components/buttons/app_elevated_button.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/error/failures.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/features/quiz/domain/entities/quiz_word.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:flutter_dic/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart' as dartz;

// Bloc
part 'presentation/bloc/quiz_bloc.dart';
part 'presentation/bloc/quiz_state.dart';

// Widgets
part 'presentation/widgets/quiz/quiz_content.dart';
part 'presentation/widgets/quiz/quiz_error_view.dart';
part 'presentation/widgets/quiz/quiz_initial_view.dart';
part 'presentation/widgets/quiz/quiz_in_progress_view.dart';
part 'presentation/widgets/quiz/quiz_question.dart';
part 'presentation/widgets/quiz/quiz_result_view.dart';
part 'presentation/widgets/results/results_tab.dart';
part 'presentation/widgets/quiz/quiz_loading_view.dart';

// Dialogs
part 'presentation/widgets/quiz/quiz_restart_dialog.dart';
part 'presentation/widgets/quiz/quiz_cancel_dialog.dart';

// Screens
part 'presentation/screens/quiz_screen.dart';
