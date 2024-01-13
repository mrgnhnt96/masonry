import 'package:brick_oven/domain/take_2/include_config.dart';
import 'package:brick_oven/domain/take_2/utils/variables_mixin.dart';

abstract class Include extends IncludeConfig with VariablesMixin {
  Include(super.config) : super.self();

  String apply(String path);
}
