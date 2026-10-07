import 'package:flutter/material.dart';

/// ANSI 转义码解析：把日志里的 `\x1b[...m` 转成带颜色的 TextSpan。
/// 青龙网页端会渲染 ANSI 颜色，App 端原本是纯文本直出导致乱码，这里补上解析层。
class AnsiText {
  AnsiText._();

  static final RegExp _ansiReg = RegExp('\x1b\\[([0-9;]*)m');

  /// 标准 16 色 + 亮色前景映射（VSCode 终端风格，与青龙网页端接近）
  static const Map<int, Color> _fgColors = {
    30: Color(0xFF000000), // black
    31: Color(0xFFCD3131), // red
    32: Color(0xFF0DBC79), // green
    33: Color(0xFFE5E510), // yellow
    34: Color(0xFF2472C8), // blue
    35: Color(0xFFBC3FBC), // magenta
    36: Color(0xFF11A8CD), // cyan
    37: Color(0xFFE5E5E5), // white
    90: Color(0xFF666666), // bright black (gray)
    91: Color(0xFFF14C4C), // bright red
    92: Color(0xFF23D18B), // bright green
    93: Color(0xFFF5F543), // bright yellow
    94: Color(0xFF3B8EEA), // bright blue
    95: Color(0xFFD670D6), // bright magenta
    96: Color(0xFF29B8DB), // bright cyan
    97: Color(0xFFFFFFFF), // bright white
  };

  /// 把含 ANSI 转义码的日志文本转成带颜色的 [TextSpan]。
  static TextSpan build(String text, TextStyle baseStyle) {
    if (text.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    Color? color;
    FontWeight? fontWeight;
    bool dim = false;

    StringBuffer buffer = StringBuffer();

    void flush() {
      if (buffer.isEmpty) return;
      TextStyle style = baseStyle;
      if (color != null) style = style.copyWith(color: color);
      if (fontWeight != null) style = style.copyWith(fontWeight: fontWeight);
      if (dim) {
        final Color? c = style.color;
        if (c != null) {
          style = style.copyWith(color: Color.lerp(c, Colors.black, 0.5));
        } else {
          style = style.copyWith(color: Colors.grey);
        }
      }
      spans.add(TextSpan(text: buffer.toString(), style: style));
      buffer.clear();
    }

    int last = 0;
    for (final m in _ansiReg.allMatches(text)) {
      buffer.write(text.substring(last, m.start));
      flush();

      final String params = m.group(1) ?? '';
      if (params.isEmpty) {
        color = null;
        fontWeight = null;
        dim = false;
      } else {
        for (final p in params.split(';')) {
          final int? n = int.tryParse(p.trim());
          if (n == null) continue;
          if (n == 0) {
            color = null;
            fontWeight = null;
            dim = false;
          } else if (n == 1) {
            fontWeight = FontWeight.bold;
          } else if (n == 2) {
            dim = true;
          } else if (n == 22) {
            fontWeight = null;
          } else if (n >= 30 && n <= 37) {
            color = _fgColors[n];
            dim = false;
          } else if (n >= 90 && n <= 97) {
            color = _fgColors[n];
            dim = false;
          }
        }
      }
      last = m.end;
    }
    buffer.write(text.substring(last));
    flush();

    if (spans.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }
    return TextSpan(style: baseStyle, children: spans);
  }
}
