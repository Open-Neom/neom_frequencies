import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/data/firestore/frequency_firestore.dart';
import 'package:neom_core/domain/model/app_profile.dart';
import 'package:neom_core/domain/model/neom/neom_frequency.dart';
import 'package:neom_core/domain/use_cases/app_drawer_service.dart';
import 'package:neom_core/domain/use_cases/frequency_service.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/utils/constants/data_assets.dart';
import 'package:neom_core/utils/neom_error_logger.dart';
import 'package:sint/sint.dart';

class FrequencyController extends SintController implements FrequencyService {
  static const int maxLoadedAssetFrequencies = 2000;
  static const int maxAssetJsonChars = 2 * 1024 * 1024;
  static const Set<String> _forbiddenKeys = <String>{
    '__proto__',
    'constructor',
    'prototype',
  };
  static final RegExp _controlOrBidiPattern = RegExp(
    r'[\x00-\x1F\x7F-\x9F\u0085\u061C\u200B-\u200F\u2028-\u202E\u2060-\u2064\u2066-\u2069\uFEFF]',
  );
  static final RegExp _encodedTraversalPattern = RegExp(
    r'%(?:00|2e|2f|5c|25|c2%[89][0-9a-f]|d8%9c|e2%80%(?:8[b-f]|a[8-e])|e2%81%a[0-9]|ef%bb%bf)',
    caseSensitive: false,
  );

  static bool isSafeFrequencyId(String raw) {
    if (raw.isEmpty || raw.length > 128) return false;
    if (_controlOrBidiPattern.hasMatch(raw)) return false;
    if (raw.trim() != raw) return false;
    if (raw == '.' ||
        raw == '..' ||
        raw.contains('/') ||
        raw.contains(r'\') ||
        _encodedTraversalPattern.hasMatch(raw)) {
      return false;
    }
    if (_forbiddenKeys.contains(raw.toLowerCase()) ||
        (raw.startsWith('__') && raw.endsWith('__'))) {
      return false;
    }
    return true;
  }

  final userServiceImpl = Sint.isRegistered<UserService>() ? Sint.find<UserService>() : null;

  final RxMap<String, NeomFrequency> _frequencies = <String, NeomFrequency>{}.obs;
  final RxMap<String, NeomFrequency> favFrequencies = <String,NeomFrequency>{}.obs;
  final RxMap<String, NeomFrequency> sortedFrequencies = <String,NeomFrequency>{}.obs;  

  final RxBool isLoading = true.obs;  

  AppProfile profile = AppProfile();

  @override
  void onInit() async {
    super.onInit();
    AppConfig.logger.d("Frequencies Init");

    if(userServiceImpl != null) {
      profile = userServiceImpl!.profile;
    }


    try {
      await loadFrequencies();

      if(profile.frequencies != null) {
        favFrequencies.value = profile.frequencies!;
      }

      sortFavFrequencies();
    } catch (e, st) {
      NeomErrorLogger.recordError(e, st, module: 'neom_frequencies', operation: 'onInit');
    }

  }

  @override
  Future<void> loadFrequencies() async {
    AppConfig.logger.d("Loading Frequencies");

    try {
      if (isSafeFrequencyId(profile.id)) {
        profile.frequencies = await FrequencyFirestore().retrieveFrequencies(profile.id);
      }

      final String frequencyStr = await rootBundle.loadString(DataAssets.frequenciesJsonPath);
      if (frequencyStr.length > maxAssetJsonChars) {
        throw StateError('Frequencies asset exceeds maxAssetJsonChars');
      }
      final dynamic decoded = jsonDecode(frequencyStr);
      if (decoded is List) {
        for (final freqJSON in decoded.take(maxLoadedAssetFrequencies)) {
          try {
            final NeomFrequency freq = NeomFrequency.fromAssetJSON(freqJSON);
            if (isSafeFrequencyId(freq.id)) {
              _frequencies[freq.id] = freq;
            }
          } catch (e, st) {
            NeomErrorLogger.recordError(
              e,
              st,
              module: 'neom_frequencies',
              operation: 'loadFrequencies.item',
            );
          }
        }
      }

      AppConfig.logger.d("${_frequencies.length} loaded frequencies from json");
    } finally {
      isLoading.value = false;
      update([AppPageIdConstants.frequencies]);
    }
  }

  @override
  Future<void> addFrequency(int index) async {
    AppConfig.logger.d("");
    if (index < 0 || index >= sortedFrequencies.length) return;

    final NeomFrequency frequency = sortedFrequencies.values.elementAt(index);
    if (!isSafeFrequencyId(frequency.id)) return;
    sortedFrequencies[frequency.id]?.isFav = true;

    AppConfig.logger.i("Adding frequency ${frequency.name}");
    if (profile.id.isEmpty) {
      favFrequencies[frequency.id] = frequency;
    } else if (isSafeFrequencyId(profile.id) &&
        await FrequencyFirestore().addFrequency(profileId: profile.id, frequency: frequency)) {
      favFrequencies[frequency.id] = frequency;
    }

    sortFavFrequencies();
    update([AppPageIdConstants.frequencies]);
  }

  @override
  Future<void> removeFrequency(int index) async {
    AppConfig.logger.d("Removing Instrument");
    if (index < 0 || index >= sortedFrequencies.length) return;
    final NeomFrequency frequency = sortedFrequencies.values.elementAt(index);
    if (!isSafeFrequencyId(frequency.id)) return;

    sortedFrequencies[frequency.id]?.isFav = false;
    AppConfig.logger.d("Removing frequency ${frequency.name}");

    if (profile.id.isEmpty) {
      favFrequencies.remove(frequency.id);
    } else if (isSafeFrequencyId(profile.id) &&
        await FrequencyFirestore().removeFrequency(profileId: profile.id, frequencyId: frequency.id)) {
      favFrequencies.remove(frequency.id);
    }

    sortFavFrequencies();
    update([AppPageIdConstants.frequencies]);
  }

  @override
  void makeMainFrequency(NeomFrequency frequency) {
    AppConfig.logger.d("Main frequency ${frequency.name}");
    if (!isSafeFrequencyId(frequency.id)) return;

    String prevInstrId = "";
    for (final instr in favFrequencies.values) {
      if (instr.isMain) {
        instr.isMain = false;
        prevInstrId = instr.id;
      }
    }
    frequency.isMain = true;
    frequency.isFav = true;
    favFrequencies[frequency.id] = frequency;
    if (isSafeFrequencyId(profile.id)) {
      unawaited(() async {
        try {
          await FrequencyFirestore().updateMainFrequency(
            profileId: profile.id,
            frequencyId: frequency.id,
            prevInstrId: prevInstrId,
          );
        } catch (e, st) {
          NeomErrorLogger.recordError(
            e,
            st,
            module: 'neom_frequencies',
            operation: 'makeMainFrequency',
          );
        }
      }());
    }

    (profile.frequencies ??= <String, NeomFrequency>{})[frequency.id] = frequency;
    if (Sint.isRegistered<AppDrawerService>()) {
      Sint.find<AppDrawerService>().updateProfile(profile);
    }
    sortFavFrequencies();
    update([AppPageIdConstants.frequencies]);
  }

  @override
  void sortFavFrequencies(){

    sortedFrequencies.value = {};

    for (var frequency in _frequencies.values) {
      if (favFrequencies.containsKey(frequency.id)) {
        sortedFrequencies[frequency.id] = favFrequencies[frequency.id]!;
      }
    }

    for (var frequency in _frequencies.values) {
      if (!favFrequencies.containsKey(frequency.id)) {
        sortedFrequencies[frequency.id] = _frequencies[frequency.id]!;
      }
    }
  }

  @override
  Map<String, NeomFrequency> get frequencies => _frequencies.value;

  bool _isClosed = false;

  @override
  void onClose() {
    if (_isClosed) return;
    _isClosed = true;
    _frequencies.close();
    favFrequencies.close();
    sortedFrequencies.close();
    isLoading.close();
    super.onClose();
  }

}
