import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_design/flutter_design.dart';
import 'package:flutter_design_viewer/src/measures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

class PatternedBackground extends StatelessWidget {
  const PatternedBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _PatternPainter(Theme.of(context)),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final ThemeData theme;

  _PatternPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    Dots(
      bgColor: theme.scaffoldBackgroundColor,
      fgColor: theme.disabledColor,
      featuresCount: 200,
    ).paintOnRect(
      canvas,
      size,
      rect,
      patternScaleBehavior: PatternScaleBehavior.customRect,
      customRect: rect,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ThemableGlyph extends StatelessWidget {
  final ViewerGlyphUnion glyph;
  final bool useTheme;

  const ThemableGlyph({
    required this.glyph,
    this.useTheme = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return glyph.when(
      icon: (icon, color, size) => Icon(
        icon,
        size: size,
        color: color ?? (useTheme ? theme.colorScheme.onBackground : null),
      ),
      image: (image, color, size) => ThemableImage(
          uri: image, width: size, height: size, useTheme: false, color: color),
    );
  }
}

class ThemableImage extends StatelessWidget {
  final String uri;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final bool useTheme;
  const ThemableImage({
    required this.uri,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.useTheme = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: add support to network images?
    if (uri.startsWith('http') || !uri.contains('.')) {
      throw UnimplementedError();
    }
    final targetUri = useTheme ? _convertToThemedUri(context, uri) : uri;
    if (targetUri.endsWith('.svg')) {
      return SvgPicture.asset(
        targetUri,
        width: width,
        height: height,
        fit: fit,
        color: color,
        package: 'flutter_design_viewer',
      );
    }
    return Image.asset(
      targetUri,
      width: width,
      height: height,
      fit: fit,
      color: color,
      package: 'flutter_design_viewer',
    );
  }

  String _convertToThemedUri(BuildContext context, String uri) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.light) return uri;
    final extension = uri.substring(uri.lastIndexOf('.'));
    return uri.replaceAll(extension, '_dark$extension');
  }
}

class LocaleTag extends StatelessWidget {
  final String name;
  final Locale locale;
  final TextStyle? textStyle;
  const LocaleTag({
    Key? key,
    required this.name,
    required this.locale,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: SpacingDesign.paddingAll3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flag.fromString(
            locale.countryCode!,
            width: 20,
            height: 16,
          ),
          const SizedBox(width: 5),
          Text(name, style: textStyle),
        ],
      ),
    );
  }
}