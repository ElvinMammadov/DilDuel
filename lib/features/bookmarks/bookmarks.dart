library bookmarks;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_dic/core/utils/snackbar_utils.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/shared/widgets/word_bottom_sheet.dart';
import 'package:injectable/injectable.dart';

part 'presentation/screens/bookmarks_screen.dart';
part 'presentation/bloc/bookmarks_bloc.dart';
part 'presentation/bloc/bookmarks_state.dart';
