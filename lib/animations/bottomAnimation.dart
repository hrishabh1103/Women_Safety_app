import 'dart:async';
import 'package:flutter/material.dart';

class Animator extends StatefulWidget {
  final Widget child;
  final Duration time;

  Animator(this.child, this.time);

  @override
  _AnimatorState createState() => _AnimatorState();
}

class _AnimatorState extends State<Animator> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with the provided duration
    _animationController = AnimationController(
      duration: widget.time, // Use the passed widget time for animation duration
      vsync: this,
    );

    // Set up the curved animation
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    // Start the animation after the delay specified in widget.time
    _timer = Timer(widget.time, () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0.0, (1 - _animation.value) * 20),
            child: child,
          ),
        );
      },
    );
  }
}

class WidgetAnimator extends StatelessWidget {
  final Widget child;
  final Duration animationDuration;

  // Constructor that takes child widget and optional animation duration
  WidgetAnimator(this.child, {this.animationDuration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) {
    // Pass the animation duration to Animator widget
    return Animator(child, animationDuration);
  }
}
