import 'package:flutter/foundation.dart';

const kShowMockDataButton = bool.fromEnvironment(
  'SHOW_MOCK_DATA_BUTTON',
  defaultValue: true,
) && !kReleaseMode;
