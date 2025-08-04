import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/utils/app_alerts.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_core/domain/model/neom/neom_frequency.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import '../../utils/constants/frequency_translation_constants.dart';
import '../frequency_controller.dart';

Widget buildFreqFavList(BuildContext context, FrequencyController frequencyController) {
  return ListView.separated(
    itemCount: frequencyController.favFrequencies.length,
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      NeomFrequency frequency = frequencyController.favFrequencies.values.elementAt(index);

      return ListTile(
          title: Text("${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz"),
          subtitle: Text(frequency.description, textAlign: TextAlign.justify,),
          trailing: IconButton(
              icon: const Icon(
                  CupertinoIcons.forward
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Get.toNamed(AppRouteConstants.generator,  arguments: [frequency]);
              }),
        onLongPress: () {
          frequencyController.makeMainFrequency(frequency);
          AppAlerts.showAlert(context,
              title: FrequencyTranslationConstants.frequencyPreferences.tr,
              message: "${frequency.name.tr} ${FrequencyTranslationConstants.selectedAsMainFrequency.tr}"
          );
        },
        onTap: () => Get.toNamed(AppRouteConstants.generator,  arguments: [frequency]),
      );
    },
  );
}

Widget buildFrequencyList(BuildContext context, FrequencyController frequencyController) {
  return ListView.separated(
    itemCount: frequencyController.sortedFrequencies.length,
    separatorBuilder:  (context, index) => const Divider(),
    itemBuilder: (__, index) {
      NeomFrequency frequency = frequencyController.sortedFrequencies.values.elementAt(index);
      if (frequencyController.favFrequencies[frequency.id] != null) {
        frequency = frequencyController.favFrequencies[frequency.id]!;
      }
      return ListTile(
          title: Text("${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz"),
          subtitle: Text(frequency.description, textAlign: TextAlign.justify),
          trailing: IconButton(
              icon: Icon(
                frequency.isFav ? Icons.remove : Icons.add,
              ),
              onPressed: () async {
                if(frequency.isFav) {
                  if (frequencyController.favFrequencies.length > 1) {
                    await frequencyController.removeFrequency(index);
                    if(frequencyController.favFrequencies.containsKey(frequency.id)) {
                      AppAlerts.showAlert(context,
                          title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                          message: FrequencyTranslationConstants.frequencyNotRemoved.tr
                      );
                    } else {
                      AppAlerts.showAlert(context,
                          title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                          message: FrequencyTranslationConstants.frequencyRemoved.tr
                      );
                    }
                  } else {
                    AppAlerts.showAlert(context,
                        title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                        message: FrequencyTranslationConstants.atLeastOneFrequency.tr
                    );
                  }
                } else {
                  await frequencyController.addFrequency(index);
                  if(frequencyController.favFrequencies.containsKey(frequency.id)) {
                    AppAlerts.showAlert(context,
                        title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                        message: FrequencyTranslationConstants.frequencyAdded.tr
                    );
                  } else {
                    AppAlerts.showAlert(context,
                        title: "${AppTranslationConstants.frequency.tr} ${frequency.frequency.toString()} Hz",
                        message: FrequencyTranslationConstants.frequencyNotAdded.tr
                    );
                  }
                }
              }
          ),
          onTap: () => Get.toNamed(AppRouteConstants.generator,  arguments: [frequency]),
      );
    },
  );
}
