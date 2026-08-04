library training;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/components/app_dropdown.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/core/utils/grammar_de_labels.dart';
import 'package:flutter_dic/core/utils/grammar_type_translator.dart';
import 'package:flutter_dic/core/utils/snackbar_utils.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';

// State & logic
part 'presentation/bloc/training_state.dart';
part 'presentation/bloc/training_cubit.dart';

// Widgets
part 'presentation/widgets/training_empty_state.dart';
part 'presentation/widgets/training_level_selector.dart';
part 'presentation/widgets/training_word_card.dart';
part 'presentation/widgets/training_nav_buttons.dart';

// Screen
part 'presentation/training_screen.dart';
