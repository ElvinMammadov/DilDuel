library search;

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/error/failures.dart';
import 'package:flutter_dic/core/state/app_cubit.dart';
import 'package:flutter_dic/core/state/app_state.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/core/utils/sizes.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/search/domain/usecases/search_word.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/di/dependency_injection.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

part 'presentation/bloc/search_bloc.dart';
part 'presentation/bloc/search_state.dart';
part 'presentation/search_screen.dart';
part 'presentation/widgets/search_section.dart';
part 'presentation/widgets/search_items.dart';
part 'presentation/widgets/search_bottom_sheet.dart';
part 'presentation/widgets/search_bottom_sheet_screen.dart';
part 'presentation/widgets/word_row.dart';