import 'package:my_bloc_app/data/di/module/network_module/network_module.dart';
import 'package:my_bloc_app/data/di/module/repository_module/repository_module.dart';

mixin DataLayerInjection {
  static Future<void> configureDataLayerInjection() async {
    await NetworkModule.configureNetworkModuleInjection();
    await RepositoryModule.configureRepositoryModuleInjection();
  }
}
