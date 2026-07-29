import 'package:flutter/widgets.dart';

import 'app_spacing.dart';

enum ScreenClass { phone, tablet, web }

ScreenClass screenClassOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < AppSpacing.breakpointPhone) return ScreenClass.phone;
  if (width < AppSpacing.breakpointTablet) return ScreenClass.tablet;
  return ScreenClass.web;
}

bool isPhone(BuildContext context) =>
    screenClassOf(context) == ScreenClass.phone;

bool isWeb(BuildContext context) => screenClassOf(context) == ScreenClass.web;
