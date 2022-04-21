// library modal_progress_hud;

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:vplus_merchant_app/widgets/network_error.dart';

// ///
// /// Wrap around any widget that makes an async call to show a modal progress
// /// indicator while the async call is in progress.
// ///
// /// The progress indicator can be turned on or off using [inAsyncCall]
// ///
// /// The progress indicator defaults to a [CircularProgressIndicator] but can be
// /// any kind of widget
// ///
// /// The progress indicator can be positioned using [offset] otherwise it is
// /// centered
// ///
// /// The modal barrier can be dismissed using [dismissible]
// ///
// /// The color of the modal barrier can be set using [color]
// ///
// /// The opacity of the modal barrier can be set using [opacity]
// ///
// /// HUD=Heads Up Display
// ///
// class ModalProgressHUD extends StatefulWidget {
//   bool inAsyncCall;
//   final double opacity;
//   final Color color;
//   final Widget progressIndicator;
//   final Offset offset;
//   final bool dismissible;
//   final Widget child;
//   final VoidCallback callback;

//   ModalProgressHUD({
//     Key key,
//     @required this.inAsyncCall,
//     this.opacity = 0.3,
//     this.color = Colors.grey,
//     this.progressIndicator = const CircularProgressIndicator(),
//     this.offset,
//     this.dismissible = false,
//     this.callback,
//     @required this.child,
//   })  : assert(child != null),
//         assert(inAsyncCall != null),
//         super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return ModalProgressHUDState();
//   }
// }

// class ModalProgressHUDState extends State<ModalProgressHUD> {
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> widgetList = [];
//     widgetList.add(widget.child);
//     // if (isTimeOut) {
//     //   return NetErrorWidget(callback: () {
//     //     isTimeOut = false;
//     //     widget.inAsyncCall = false;
//     //     isRetry = true;
//     //     widget.callback();
//     //   });
//     // }

//     if (widget.inAsyncCall) {
//       // Future.delayed(Duration(seconds: 5), () {
//       //   if (!mounted) return;
//       //   setState(() {
//       //     widget.inAsyncCall = false;
//       //   });
//       // });
//       Widget layOutProgressIndicator;
//       if (widget.offset == null)
//         layOutProgressIndicator = Center(child: widget.progressIndicator);
//       else {
//         layOutProgressIndicator = Positioned(
//           child: widget.progressIndicator,
//           left: widget.offset.dx,
//           top: widget.offset.dy,
//         );
//       }
//       final modal = [
//         new Opacity(
//           child: new ModalBarrier(
//               dismissible: widget.dismissible, color: widget.color),
//           opacity: widget.opacity,
//         ),
//         layOutProgressIndicator
//       ];
//       widgetList += modal;
//     }
//     return new Stack(
//       children: widgetList,
//     );
//   }
// }
