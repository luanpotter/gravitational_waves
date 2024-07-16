import 'package:flutter/material.dart';
import 'package:gravitational_waves/widgets/palette.dart';
import 'package:url_launcher/url_launcher.dart';

class Label extends Text {
  Label({
    required String label,
    super.key,
    Color fontColor = Colors.white,
    double fontSize = 12.0,
    TextAlign? textAlign,
  }) : super(
          label,
          textAlign: textAlign,
          style: TextStyle(
            color: fontColor,
            fontSize: fontSize,
            fontFamily: 'Quantum',
          ),
        );
}

class Link extends StatelessWidget {
  final String link;
  final double fontSize;

  const Link({required this.link, required this.fontSize, super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _onTap,
        child: Label(
          label: link,
          fontSize: fontSize,
          fontColor: PaletteColors.pinks.light,
        ),
      );

  Future<void> _onTap() async {
    final url = Uri.http(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
