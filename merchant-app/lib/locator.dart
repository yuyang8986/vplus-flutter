import 'package:get_it/get_it.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';

var locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Current_OrderStatus_Provider());
}
