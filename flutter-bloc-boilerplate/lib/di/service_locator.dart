import 'package:get_it/get_it.dart';
import 'package:my_bloc_app/data/di/data_layer_injection.dart';
import 'package:my_bloc_app/domain/di/domain_layer_injection.dart';
import 'package:my_bloc_app/presentation/di/presentation_layer_injection.dart';

final getIt = GetIt.instance;

mixin ServiceLocator {
  static Future<void> configureDependencies() async {
    await DataLayerInjection.configureDataLayerInjection();
    await DomainLayerInjection.configureDomainLayerInjection();
    await PresentationLayerInjection.configurePresentationLayerInjection();
  }
}
