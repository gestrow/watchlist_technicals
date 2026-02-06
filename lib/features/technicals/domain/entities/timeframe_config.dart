import 'package:equatable/equatable.dart';

/// Configuration for technical analysis based on trading timeframe.
///
/// Each timeframe preset contains indicator parameters optimized for
/// different trading horizons (intraday, swing, long-term).
class TimeframeConfig extends Equatable {
  final String name;
  final int rsiPeriod;
  final int rsiOverbought;
  final int rsiOversold;
  final List<int> emaPeriods;
  final bool useSMA;
  final int macdFast;
  final int macdSlow;
  final int macdSignal;
  final int bollingerPeriod;
  final double bollingerStdDev;
  final int vwapPeriod;

  const TimeframeConfig({
    required this.name,
    required this.rsiPeriod,
    required this.rsiOverbought,
    required this.rsiOversold,
    required this.emaPeriods,
    required this.useSMA,
    required this.macdFast,
    required this.macdSlow,
    required this.macdSignal,
    required this.bollingerPeriod,
    required this.bollingerStdDev,
    required this.vwapPeriod,
  });

  /// Creates a copy with updated fields.
  TimeframeConfig copyWith({
    String? name,
    int? rsiPeriod,
    int? rsiOverbought,
    int? rsiOversold,
    List<int>? emaPeriods,
    bool? useSMA,
    int? macdFast,
    int? macdSlow,
    int? macdSignal,
    int? bollingerPeriod,
    double? bollingerStdDev,
    int? vwapPeriod,
  }) {
    return TimeframeConfig(
      name: name ?? this.name,
      rsiPeriod: rsiPeriod ?? this.rsiPeriod,
      rsiOverbought: rsiOverbought ?? this.rsiOverbought,
      rsiOversold: rsiOversold ?? this.rsiOversold,
      emaPeriods: emaPeriods ?? this.emaPeriods,
      useSMA: useSMA ?? this.useSMA,
      macdFast: macdFast ?? this.macdFast,
      macdSlow: macdSlow ?? this.macdSlow,
      macdSignal: macdSignal ?? this.macdSignal,
      bollingerPeriod: bollingerPeriod ?? this.bollingerPeriod,
      bollingerStdDev: bollingerStdDev ?? this.bollingerStdDev,
      vwapPeriod: vwapPeriod ?? this.vwapPeriod,
    );
  }

  /// Intraday timeframe (0-3 days).
  /// Optimized for quick trades with faster indicator settings.
  static const TimeframeConfig intraday = TimeframeConfig(
    name: 'Intraday',
    rsiPeriod: 9,
    rsiOverbought: 80,
    rsiOversold: 20,
    emaPeriods: [9],
    useSMA: false,
    macdFast: 5,
    macdSlow: 13,
    macdSignal: 1,
    bollingerPeriod: 20,
    bollingerStdDev: 2.0,
    vwapPeriod: 9,
  );

  /// Swing timeframe (3-10 days).
  /// Balanced settings for medium-term trading.
  static const TimeframeConfig swing = TimeframeConfig(
    name: 'Swing',
    rsiPeriod: 11,
    rsiOverbought: 75,
    rsiOversold: 25,
    emaPeriods: [13, 50],
    useSMA: false,
    macdFast: 12,
    macdSlow: 26,
    macdSignal: 9,
    bollingerPeriod: 20,
    bollingerStdDev: 2.0,
    vwapPeriod: 13,
  );

  /// Long timeframe (10-21 days).
  /// Settings for longer-term position trading.
  static const TimeframeConfig long = TimeframeConfig(
    name: 'Long',
    rsiPeriod: 14,
    rsiOverbought: 70,
    rsiOversold: 30,
    emaPeriods: [20],
    useSMA: true,
    macdFast: 12,
    macdSlow: 26,
    macdSignal: 9,
    bollingerPeriod: 20,
    bollingerStdDev: 2.0,
    vwapPeriod: 20,
  );

  /// All available preset timeframe configurations.
  static const List<TimeframeConfig> presets = [intraday, swing, long];

  @override
  List<Object?> get props => [
        name,
        rsiPeriod,
        rsiOverbought,
        rsiOversold,
        emaPeriods,
        useSMA,
        macdFast,
        macdSlow,
        macdSignal,
        bollingerPeriod,
        bollingerStdDev,
        vwapPeriod,
      ];
}
