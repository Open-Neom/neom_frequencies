import 'package:sint/sint.dart';

import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'ui/frequency_page.dart';
import 'ui/root_frequencies_page.dart';

class FrequencyRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
      name: AppRouteConstants.frequencyFav,
      page: () => const RootFrequenciesPage(),
      transition: Transition.leftToRight,
    ),
    SintPage(
      name: AppRouteConstants.frequency,
      page: () => const FrequencyPage(),
      transition: Transition.rightToLeft,
    ),
  ];

}
