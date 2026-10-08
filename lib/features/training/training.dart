library training;

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/components/app_back_bar.dart';
import 'package:flutter_dic/core/components/app_bottom_sheet.dart';
import 'package:flutter_dic/core/components/app_card.dart';
import 'package:flutter_dic/core/components/app_filled_card.dart';
import 'package:flutter_dic/core/components/app_filled_card_list.dart';
import 'package:flutter_dic/core/components/app_snackbar.dart';
import 'package:flutter_dic/core/components/buttons/app_elevated_button.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/core/utils/grammar_de_labels.dart';
import 'package:flutter_dic/core/utils/grammar_type_translator.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_tts/flutter_tts.dart';

// State & logic
part 'presentation/bloc/training_state.dart';
part 'presentation/bloc/training_cubit.dart';

// Widgets
part 'presentation/widgets/training_level_selector.dart';
part 'presentation/widgets/training_word_card.dart';
part 'presentation/widgets/training_nav_buttons.dart';
part 'presentation/widgets/training_jump_sheet.dart';

// Screen
part 'presentation/training_screen.dart';
