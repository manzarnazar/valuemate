
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class Body extends StatelessWidget {
  final Widget child;
  final bool showLoader;

  const Body({Key? key, required this.child, this.showLoader = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      height: context.height(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          // if (showLoader) Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
