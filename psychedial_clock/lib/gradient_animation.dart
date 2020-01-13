import 'package:flutter/material.dart';

class GradientAnimation extends StatefulWidget {
	// final LinearGradient begin;
	// final LinearGradient end;
	final AnimationController controller;
	final List<Gradient> gradients;
	final Function childWidget;

	const GradientAnimation({
		Key key,
		@required this.controller,
		// @required this.begin,
		// @required this.end,
		@required this.gradients,
		@required this.childWidget,
	}) : super(key: key);

	@override
	_GradientAnimationState createState() => _GradientAnimationState();
}

class _GradientAnimationState extends State<GradientAnimation> {
	Animation<Gradient> _animation;

	@override
	void initState() {
		runTweenSequence();
		super.initState();
	}

	void runTweenSequence() {
		List<Gradient> auxGradients = new List.from(widget.gradients);
		auxGradients.addAll(widget.gradients);

		_animation = TweenSequence([
			TweenSequenceItem(
				tween: LinearGradientTween(begin: auxGradients[0], end: auxGradients[1]),
				weight: 100 / 5
			),
			TweenSequenceItem(
				tween: LinearGradientTween(begin: auxGradients[1], end: auxGradients[2]),
				weight: 100 / 5
			),
			TweenSequenceItem(
				tween: LinearGradientTween(begin: auxGradients[2], end: auxGradients[3]),
				weight: 100 / 5
			),
			TweenSequenceItem(
				tween: LinearGradientTween(begin: auxGradients[3], end: auxGradients[4]),
				weight: 100 / 5
			),
			TweenSequenceItem(
				tween: LinearGradientTween(begin: auxGradients[4], end: auxGradients[5]),
				weight: 100 / 5
			),
			TweenSequenceItem(
				tween: LinearGradientTween(begin: auxGradients[5], end: auxGradients[6]),
				weight: 100 / 5
			),
		]).animate(widget.controller);

		// List<TweenSequenceItem> sequence = new List();
		// for (var i = 0; i <= widget.gradients.length; i++) {
		// 	sequence.add(
		// 		TweenSequenceItem(
		// 			tween: LinearGradientTween(begin: auxGradients[i], end: auxGradients[i + 1]),
		// 			weight: 100 / widget.gradients.length
		// 		),
		// 	);
		// }
		// _animation = TweenSequence(sequence).animate(widget.controller);
	}

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: _animation,
			builder: (context, _) {
				return widget.childWidget(_animation.value);
			}
		);
	}
}

class LinearGradientTween extends Tween<LinearGradient> {
	LinearGradientTween({
		LinearGradient begin,
		LinearGradient end,
	}) : super(begin: begin, end: end);

	@override
	LinearGradient lerp(double t) => LinearGradient.lerp(begin, end, t);
}
