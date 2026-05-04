import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'custom_snack_bar.dart';

class CustomScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? extendBody;
  final bool extendBodyBehindAppBar;
  final bool enableDoubleTapExit;
  final Future<bool> Function()? onWillPop;

  const CustomScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.extendBody,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.enableDoubleTapExit = false,
    this.onWillPop,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  DateTime? _lastPressed;
  bool _canPop = false;

  @override
  Widget build(BuildContext context) {
    // If we want to intercept, canPop should be false initially
    final bool shouldIntercept = widget.enableDoubleTapExit || widget.onWillPop != null;

    return PopScope(
      canPop: _canPop || !shouldIntercept,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          if (_canPop) {
            setState(() {
              _canPop = false;
            });
          }
          return;
        }

        bool shouldPop = true;
        if (widget.onWillPop != null) {
          shouldPop = await widget.onWillPop!();
        }

        if (shouldPop) {
          if (widget.enableDoubleTapExit) {
            final now = DateTime.now();
            final bool shouldShowPrompt = _lastPressed == null ||
                now.difference(_lastPressed!) > const Duration(seconds: 2);
            if (shouldShowPrompt) {
              _lastPressed = now;
              CustomSnackBar.showInfo(
                  message: "press_back_again_to_exit".tr);
            } else {
              setState(() {
                _canPop = true;
              });
              Navigator.of(context).pop();
            }
          } else {
            setState(() {
              _canPop = true;
            });
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: widget.appBar,
        drawer: widget.drawer,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
        extendBody: widget.extendBody ?? true,
        body: widget.body,
      ),
    );
  }
}
