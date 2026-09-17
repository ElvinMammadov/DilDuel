library auth;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/components/app_snackbar.dart';
import 'package:flutter_dic/core/components/buttons/app_elevated_button.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/core/data/repositories/quiz_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/sync_bookmark_repository.dart';
import 'package:flutter_dic/core/data/repositories/sync_quiz_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/sync_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'domain/auth_user.dart';
part 'domain/auth_repository.dart';
part 'data/firebase_auth_repository.dart';
part 'presentation/bloc/auth_state.dart';
part 'presentation/bloc/auth_cubit.dart';
part 'presentation/screens/sign_in_screen.dart';
part 'presentation/screens/register_screen.dart';
