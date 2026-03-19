const katexFontPackage = 'flutter_math_render_katex';

abstract final class KaTeXFontFamilies {
  static const main = 'KaTeX_Main';
  static const math = 'KaTeX_Math';
  static const ams = 'KaTeX_AMS';
  static const caligraphic = 'KaTeX_Caligraphic';
  static const fraktur = 'KaTeX_Fraktur';
  static const sansSerif = 'KaTeX_SansSerif';
  static const script = 'KaTeX_Script';
  static const typewriter = 'KaTeX_Typewriter';
  static const size1 = 'KaTeX_Size1';
  static const size2 = 'KaTeX_Size2';
  static const size3 = 'KaTeX_Size3';
  static const size4 = 'KaTeX_Size4';

  static const all = <String>[
    main,
    math,
    ams,
    caligraphic,
    fraktur,
    sansSerif,
    script,
    typewriter,
    size1,
    size2,
    size3,
    size4,
  ];

  static String packaged(String family) => 'packages/$katexFontPackage/$family';
}

const katexFontAssets = <String>[
  'lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf',
  'lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf',
  'lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf',
  'lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf',
  'lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf',
  'lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf',
  'lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf',
  'lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf',
  'lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf',
];
