import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CallbackAnimation extends SimpleAnimation {
  CallbackAnimation(
    String animationName, {
    @required this.callback,
    double mix,
  }) : super(animationName, mix: mix);

  final Function callback;

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    // Apply the animation to the artboard with the appropriate level of mix
    instance.animation.apply(instance.time, coreContext: artboard, mix: mix);

    // If false, the animation has ended (it doesn't loop)
    if (!instance.advance(elapsedSeconds)) {
      _onCompleted(callback);
    }
  }

  void _onCompleted(Function callback) {
    final start =
        instance.animation.enableWorkArea ? instance.animation.workStart : 0;
    final currentFrame = ((instance.time - start) * instance.animation.fps);
    final endFrame =
        instance.animation.enableWorkArea ? instance.animation.workEnd : 120;

    // if the animation is within one frame to the end I'll call the callback
    if (currentFrame >= endFrame - 1) {
      isActive = false;

      // addPostFrameCallback added to avoid build collision
      WidgetsBinding.instance.addPostFrameCallback((_) => callback());
    }
  }

  /// Resets the animation to its starting state and starts it
  void resetAndStart(RuntimeArtboard artboard) {
    // TODO: Move reset logic into linear animation instance
    instance.time =
        (instance.animation.enableWorkArea ? instance.animation.workStart : 0)
                .toDouble() /
            instance.animation.fps;
    isActive = true;
  }

  void resetOnly(RuntimeArtboard artboard) {
    instance.time =
        (instance.animation.enableWorkArea ? instance.animation.workStart : 0)
                .toDouble() /
            instance.animation.fps;
    isActive = false;
  }
}
