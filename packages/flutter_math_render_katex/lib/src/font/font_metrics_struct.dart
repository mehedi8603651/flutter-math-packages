class FontMetrics {
  double get cssEmPerMu => quad / 18;

  final double slant;
  final double space;
  final double stretch;
  final double shrink;
  final double xHeight;
  final double quad;
  final double extraSpace;
  final double num1;
  final double num2;
  final double num3;
  final double denom1;
  final double denom2;
  final double sup1;
  final double sup2;
  final double sup3;
  final double sub1;
  final double sub2;
  final double supDrop;
  final double subDrop;
  final double delim1;
  final double delim2;
  final double axisHeight;
  final double defaultRuleThickness;
  final double bigOpSpacing1;
  final double bigOpSpacing2;
  final double bigOpSpacing3;
  final double bigOpSpacing4;
  final double bigOpSpacing5;
  final double sqrtRuleThickness;
  final double ptPerEm;
  final double doubleRuleSep;
  final double arrayRuleWidth;
  final double fboxsep;
  final double fboxrule;

  const FontMetrics({
    required this.slant,
    required this.space,
    required this.stretch,
    required this.shrink,
    required this.xHeight,
    required this.quad,
    required this.extraSpace,
    required this.num1,
    required this.num2,
    required this.num3,
    required this.denom1,
    required this.denom2,
    required this.sup1,
    required this.sup2,
    required this.sup3,
    required this.sub1,
    required this.sub2,
    required this.supDrop,
    required this.subDrop,
    required this.delim1,
    required this.delim2,
    required this.axisHeight,
    required this.defaultRuleThickness,
    required this.bigOpSpacing1,
    required this.bigOpSpacing2,
    required this.bigOpSpacing3,
    required this.bigOpSpacing4,
    required this.bigOpSpacing5,
    required this.sqrtRuleThickness,
    required this.ptPerEm,
    required this.doubleRuleSep,
    required this.arrayRuleWidth,
    required this.fboxsep,
    required this.fboxrule,
  });

  static FontMetrics? fromMap(Map<String, double> map) {
    try {
      return FontMetrics(
        slant: map['slant']!,
        space: map['space']!,
        stretch: map['stretch']!,
        shrink: map['shrink']!,
        xHeight: map['xHeight']!,
        quad: map['quad']!,
        extraSpace: map['extraSpace']!,
        num1: map['num1']!,
        num2: map['num2']!,
        num3: map['num3']!,
        denom1: map['denom1']!,
        denom2: map['denom2']!,
        sup1: map['sup1']!,
        sup2: map['sup2']!,
        sup3: map['sup3']!,
        sub1: map['sub1']!,
        sub2: map['sub2']!,
        supDrop: map['supDrop']!,
        subDrop: map['subDrop']!,
        delim1: map['delim1']!,
        delim2: map['delim2']!,
        axisHeight: map['axisHeight']!,
        defaultRuleThickness: map['defaultRuleThickness']!,
        bigOpSpacing1: map['bigOpSpacing1']!,
        bigOpSpacing2: map['bigOpSpacing2']!,
        bigOpSpacing3: map['bigOpSpacing3']!,
        bigOpSpacing4: map['bigOpSpacing4']!,
        bigOpSpacing5: map['bigOpSpacing5']!,
        sqrtRuleThickness: map['sqrtRuleThickness']!,
        ptPerEm: map['ptPerEm']!,
        doubleRuleSep: map['doubleRuleSep']!,
        arrayRuleWidth: map['arrayRuleWidth']!,
        fboxsep: map['fboxsep']!,
        fboxrule: map['fboxrule']!,
      );
    } on Error {
      return null;
    }
  }
}
