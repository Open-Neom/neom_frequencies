import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/app_page_id_constants.dart';
import '../utils/constants/frequency_translation_constants.dart';
import 'frequency_controller.dart';
import 'widgets/frequency_widgets.dart';

class FrequencyPage extends StatelessWidget {

  final bool showAppBar;

  const FrequencyPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FrequencyController>(
      id: AppPageIdConstants.frequencies,
      init: FrequencyController(),
      builder: (controller) => Scaffold(
        appBar:  showAppBar ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBarChild(title: FrequencyTranslationConstants.frequencySelection.tr)) : null,
        body: Container(
          decoration: AppTheme.appBoxDecoration,
          child: Column(
              children: <Widget>[
                Obx(()=> Expanded(
                  child: buildFrequencyList(context, controller),
                ),),
              ]
          ),
        ),
      ),
    );
  }

}
