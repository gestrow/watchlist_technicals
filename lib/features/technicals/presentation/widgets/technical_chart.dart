import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/ohlc_model.dart';
import '../../domain/entities/technical_indicators_result.dart';
import '../../domain/entities/timeframe_config.dart';

/// A multi-panel technical chart with candlesticks, overlays, and indicators.
class TechnicalChart extends StatelessWidget {
  final TechnicalIndicatorsResult result;
  final TimeframeConfig config;

  const TechnicalChart({
    super.key,
    required this.result,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Price chart with overlays
        SizedBox(
          height: 300,
          child: _buildPriceChart(isDark),
        ),

        const SizedBox(height: 8),

        // RSI panel
        SizedBox(
          height: 120,
          child: _buildRsiChart(isDark),
        ),

        const SizedBox(height: 8),

        // MACD panel
        SizedBox(
          height: 120,
          child: _buildMacdChart(isDark),
        ),
      ],
    );
  }

  Widget _buildPriceChart(bool isDark) {
    final candles = result.candles;

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.all(8),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        numberFormat: intl.NumberFormat.decimalPattern(),
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        lineType: CrosshairLineType.both,
        lineDashArray: const <double>[5, 5],
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      ),
      series: <CartesianSeries>[
        // Candlestick series
        CandleSeries<OhlcModel, DateTime>(
          name: 'Price',
          dataSource: candles,
          xValueMapper: (data, _) => data.date,
          openValueMapper: (data, _) => data.open,
          highValueMapper: (data, _) => data.high,
          lowValueMapper: (data, _) => data.low,
          closeValueMapper: (data, _) => data.close,
          bullColor: AppColors.candleUp,
          bearColor: AppColors.candleDown,
          enableSolidCandles: true,
        ),

        // Bollinger Bands - Upper
        LineSeries<_ChartData, DateTime>(
          name: 'BB Upper',
          dataSource: _createLineData(result.bollinger.upper),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: AppColors.bbUpper.withValues(alpha: 0.7),
          width: 1,
          dashArray: const <double>[3, 3],
        ),

        // Bollinger Bands - Middle
        LineSeries<_ChartData, DateTime>(
          name: 'BB Middle',
          dataSource: _createLineData(result.bollinger.middle),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: AppColors.bbMiddle.withValues(alpha: 0.7),
          width: 1,
        ),

        // Bollinger Bands - Lower
        LineSeries<_ChartData, DateTime>(
          name: 'BB Lower',
          dataSource: _createLineData(result.bollinger.lower),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: AppColors.bbLower.withValues(alpha: 0.7),
          width: 1,
          dashArray: const <double>[3, 3],
        ),

        // EMAs/SMAs
        ...result.emas.entries.map((entry) {
          final period = entry.key;
          final values = entry.value;
          final color = _getEmaColor(period);

          return LineSeries<_ChartData, DateTime>(
            name: config.useSMA ? 'SMA($period)' : 'EMA($period)',
            dataSource: _createLineData(values),
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.value,
            color: color,
            width: 1.5,
          );
        }),

        // VWAP
        LineSeries<_ChartData, DateTime>(
          name: 'VWAP',
          dataSource: _createLineData(result.vwap),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: Colors.orange.withValues(alpha: 0.8),
          width: 1.5,
          dashArray: const <double>[5, 2],
        ),
      ],
    );
  }

  Widget _buildRsiChart(bool isDark) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.all(8),
      title: ChartTitle(
        text: 'RSI(${config.rsiPeriod})',
        textStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        alignment: ChartAlignment.near,
      ),
      primaryXAxis: DateTimeAxis(
        isVisible: false,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        interval: 25,
        plotBands: [
          // Overbought zone
          PlotBand(
            start: config.rsiOverbought,
            end: 100,
            color: AppColors.rsiOverbought.withValues(alpha: 0.1),
            borderWidth: 0,
          ),
          // Oversold zone
          PlotBand(
            start: 0,
            end: config.rsiOversold,
            color: AppColors.rsiOversold.withValues(alpha: 0.1),
            borderWidth: 0,
          ),
        ],
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: 9,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        opposedPosition: true,
      ),
      series: <CartesianSeries>[
        LineSeries<_ChartData, DateTime>(
          dataSource: _createLineData(result.rsi),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: AppColors.rsiLine,
          width: 1.5,
        ),
      ],
    );
  }

  Widget _buildMacdChart(bool isDark) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.all(8),
      title: ChartTitle(
        text: 'MACD(${config.macdFast},${config.macdSlow},${config.macdSignal})',
        textStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        alignment: ChartAlignment.near,
      ),
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: 9,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: 9,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        opposedPosition: true,
        plotBands: [
          PlotBand(
            start: 0,
            end: 0,
            borderColor: isDark ? Colors.white24 : Colors.black26,
            borderWidth: 1,
          ),
        ],
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: TextStyle(
          fontSize: 9,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      series: <CartesianSeries>[
        // MACD Histogram
        ColumnSeries<_ChartData, DateTime>(
          name: 'Histogram',
          dataSource: _createLineData(result.macd.histogram),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          pointColorMapper: (data, _) =>
              (data.value ?? 0) >= 0 ? AppColors.candleUp : AppColors.candleDown,
          width: 0.6,
          borderWidth: 0,
        ),

        // MACD Line
        LineSeries<_ChartData, DateTime>(
          name: 'MACD',
          dataSource: _createLineData(result.macd.macdLine),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: AppColors.macdLine,
          width: 1.5,
        ),

        // Signal Line
        LineSeries<_ChartData, DateTime>(
          name: 'Signal',
          dataSource: _createLineData(result.macd.signalLine),
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.value,
          color: AppColors.macdSignal,
          width: 1.5,
        ),
      ],
    );
  }

  List<_ChartData> _createLineData(List<double?> values) {
    final data = <_ChartData>[];
    final candles = result.candles;

    for (int i = 0; i < candles.length && i < values.length; i++) {
      if (values[i] != null) {
        data.add(_ChartData(candles[i].date, values[i]));
      }
    }

    return data;
  }

  Color _getEmaColor(int period) {
    // Different colors for different periods
    if (period <= 10) return Colors.cyan;
    if (period <= 20) return Colors.blue;
    if (period <= 50) return Colors.purple;
    return Colors.pink;
  }
}

class _ChartData {
  final DateTime date;
  final double? value;

  _ChartData(this.date, this.value);
}
