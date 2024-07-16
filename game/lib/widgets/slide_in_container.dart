import 'package:flutter/widgets.dart';

class SlideInContainer extends StatefulWidget {
  final Widget child;
  final Offset from;
  final Offset to;
  final Duration duration;
  final Curve curve;

  const SlideInContainer({
    required this.child,
    super.key,
    this.from = Offset.zero,
    this.to = Offset.zero,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeInExpo,
  });

  @override
  SlideInContainerState createState() => SlideInContainerState();
}

class SlideInContainerState extends State<SlideInContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: widget.from,
      end: widget.to,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
