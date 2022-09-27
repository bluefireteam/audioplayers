/// [jsNum] the duration in seconds
Duration toDuration(num jsNum) => Duration(
      seconds: (jsNum.isNaN || jsNum.isInfinite ? 0 : jsNum).round(),
    );
