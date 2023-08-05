import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArguments on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      //Extracting the arguments.
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        // Returning the arguments.
        return args as T;
      }
    }
    return null;
  }
}
