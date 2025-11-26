// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: env/dev.env
final class _Dev {
  static const String baseUrl = 'https://dev';

  static const List<int> _enviedkeysecretKey = <int>[
    498602106,
    2421618351,
    749984066,
  ];

  static const List<int> _envieddatasecretKey = <int>[
    498602014,
    2421618378,
    749984052,
  ];

  static final String secretKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatasecretKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatasecretKey[i] ^ _enviedkeysecretKey[i]),
  );
}

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: env/prod.env
final class _Prod {
  static const List<int> _enviedkeybaseUrl = <int>[
    4005889543,
    586295378,
    873053160,
    493073661,
    3383142020,
    1203330730,
    2019072724,
    755483713,
    1060015212,
    117092529,
    3054193678,
    3100481990,
  ];

  static const List<int> _envieddatabaseUrl = <int>[
    4005889647,
    586295334,
    873053084,
    493073549,
    3383142135,
    1203330704,
    2019072763,
    755483758,
    1060015132,
    117092547,
    3054193761,
    3100481954,
  ];

  static final String baseUrl = String.fromCharCodes(
    List<int>.generate(
      _envieddatabaseUrl.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatabaseUrl[i] ^ _enviedkeybaseUrl[i]),
  );

  static const List<int> _enviedkeysecretKey = <int>[
    2010537539,
    2323575366,
    3160446693,
    2053536400,
  ];

  static const List<int> _envieddatasecretKey = <int>[
    2010537523,
    2323575348,
    3160446602,
    2053536500,
  ];

  static final String secretKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatasecretKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatasecretKey[i] ^ _enviedkeysecretKey[i]),
  );
}

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: env/stage.env
final class _Stage {
  static const List<int> _enviedkeybaseUrl = <int>[
    864656130,
    824017602,
    3652227866,
    3967277724,
    3509779151,
    3262150858,
    2472595515,
    667570876,
    3251196763,
    658009909,
    2035112334,
    2728205532,
    1792922221,
  ];

  static const List<int> _envieddatabaseUrl = <int>[
    864656234,
    824017590,
    3652227950,
    3967277804,
    3509779132,
    3262150896,
    2472595476,
    667570835,
    3251196712,
    658009921,
    2035112431,
    2728205499,
    1792922120,
  ];

  static final String baseUrl = String.fromCharCodes(
    List<int>.generate(
      _envieddatabaseUrl.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatabaseUrl[i] ^ _enviedkeybaseUrl[i]),
  );

  static const List<int> _enviedkeysecretKey = <int>[
    46848387,
    3783241791,
    571323314,
    3125800448,
    2937512685,
  ];

  static const List<int> _envieddatasecretKey = <int>[
    46848496,
    3783241803,
    571323347,
    3125800551,
    2937512584,
  ];

  static final String secretKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatasecretKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatasecretKey[i] ^ _enviedkeysecretKey[i]),
  );
}
