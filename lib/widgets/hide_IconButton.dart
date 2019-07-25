import 'package:flutter/material.dart';

class VisibleIconButton extends StatelessWidget {
  const VisibleIconButton({Key key, this.icon, this.visible, this.onPressed})
      : super(key: key);

  @required
  final bool visible;

  @required
  final Widget icon;

  @required
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return visible
        ? IconButton(
            icon: icon,
            onPressed: this.onPressed,
          )
        : new Container(height: 0.0, width: 0.0);
  }
}
