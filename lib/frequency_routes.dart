import 'package:neom_core/ui/deferred_loader.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:sint/sint.dart';

import 'ui/frequency_page.dart' deferred as freq;
import 'ui/root_frequencies_page.dart' deferred as rootFreq;

class FrequencyRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
      name: AppRouteConstants.frequencyFav,
      page: () => DeferredLoader(rootFreq.loadLibrary, () => rootFreq.RootFrequenciesPage()),
      transition: Transition.leftToRight,
    ),
    SintPage(
      name: AppRouteConstants.frequency,
      page: () => DeferredLoader(freq.loadLibrary, () => freq.FrequencyPage()),
      transition: Transition.rightToLeft,
    ),
  ];

}
