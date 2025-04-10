import 'package:flutter/material.dart';

// Custom slide transition for right-to-left navigation
class SlideTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  final Offset beginOffset;
  final Duration transitionduration;

  SlideTransitionRoute({
    required this.widget,
    required this.beginOffset,
    required this.transitionduration,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) {
           debugPrint("SlideRightRoute triggered for ${widget.runtimeType}");
           return widget;
         },
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           debugPrint("SlideRightRoute animation running");
           var tween = Tween(
             begin: beginOffset,
             end: Offset.zero,
           ).chain(CurveTween(curve: Curves.easeInOut));
           var offsetAnimation = animation.drive(tween);

           return SlideTransition(position: offsetAnimation, child: child);
         },
         transitionDuration: transitionduration,
         reverseTransitionDuration: transitionduration,
       );
}
