import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class ExpandableListTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool initiallyExpanded;

  const ExpandableListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  ExpandableListTileState createState() => ExpandableListTileState();
}

class ExpandableListTileState extends State<ExpandableListTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.25);

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });

    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildTile(BuildContext context, Widget? child) {
    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: _handleTap,
            child: Row(
              children: <Widget>[
                if (widget.leading != null) widget.leading!,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.title,
                        if (widget.subtitle != null) widget.subtitle!,
                      ],
                    ),
                  ),
                ),
                widget.trailing ??
                    RotationTransition(
                      turns: _iconTurns,
                      child: const Icon(Icons.chevron_right),
                    ),
              ],
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildTile,
      child: closed
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.children,
            ),
    );
  }
}
