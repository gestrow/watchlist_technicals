import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/timeframe_config.dart';

/// Dialog for customizing timeframe parameters.
class CustomTimeframeDialog extends StatefulWidget {
  final TimeframeConfig? initialConfig;

  const CustomTimeframeDialog({
    super.key,
    this.initialConfig,
  });

  /// Shows the dialog and returns the configured TimeframeConfig or null if cancelled.
  static Future<TimeframeConfig?> show(
    BuildContext context, {
    TimeframeConfig? initialConfig,
  }) {
    return showDialog<TimeframeConfig>(
      context: context,
      builder: (context) => CustomTimeframeDialog(initialConfig: initialConfig),
    );
  }

  @override
  State<CustomTimeframeDialog> createState() => _CustomTimeframeDialogState();
}

class _CustomTimeframeDialogState extends State<CustomTimeframeDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rsiPeriodController;
  late TextEditingController _rsiOverboughtController;
  late TextEditingController _rsiOversoldController;
  late TextEditingController _emaPeriodsController;
  late TextEditingController _macdFastController;
  late TextEditingController _macdSlowController;
  late TextEditingController _macdSignalController;
  late TextEditingController _bollingerPeriodController;
  late TextEditingController _bollingerStdDevController;
  late TextEditingController _vwapPeriodController;

  late bool _useSMA;

  @override
  void initState() {
    super.initState();
    final config = widget.initialConfig ?? TimeframeConfig.intraday;

    _rsiPeriodController = TextEditingController(text: config.rsiPeriod.toString());
    _rsiOverboughtController = TextEditingController(text: config.rsiOverbought.toString());
    _rsiOversoldController = TextEditingController(text: config.rsiOversold.toString());
    _emaPeriodsController = TextEditingController(text: config.emaPeriods.join(', '));
    _macdFastController = TextEditingController(text: config.macdFast.toString());
    _macdSlowController = TextEditingController(text: config.macdSlow.toString());
    _macdSignalController = TextEditingController(text: config.macdSignal.toString());
    _bollingerPeriodController = TextEditingController(text: config.bollingerPeriod.toString());
    _bollingerStdDevController = TextEditingController(text: config.bollingerStdDev.toString());
    _vwapPeriodController = TextEditingController(text: config.vwapPeriod.toString());
    _useSMA = config.useSMA;
  }

  @override
  void dispose() {
    _rsiPeriodController.dispose();
    _rsiOverboughtController.dispose();
    _rsiOversoldController.dispose();
    _emaPeriodsController.dispose();
    _macdFastController.dispose();
    _macdSlowController.dispose();
    _macdSignalController.dispose();
    _bollingerPeriodController.dispose();
    _bollingerStdDevController.dispose();
    _vwapPeriodController.dispose();
    super.dispose();
  }

  List<int> _parseEmaPeriods(String input) {
    return input
        .split(RegExp(r'[,\s]+'))
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((n) => n > 0)
        .toList();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final config = TimeframeConfig(
        name: 'Custom',
        rsiPeriod: int.parse(_rsiPeriodController.text),
        rsiOverbought: int.parse(_rsiOverboughtController.text),
        rsiOversold: int.parse(_rsiOversoldController.text),
        emaPeriods: _parseEmaPeriods(_emaPeriodsController.text),
        useSMA: _useSMA,
        macdFast: int.parse(_macdFastController.text),
        macdSlow: int.parse(_macdSlowController.text),
        macdSignal: int.parse(_macdSignalController.text),
        bollingerPeriod: int.parse(_bollingerPeriodController.text),
        bollingerStdDev: double.parse(_bollingerStdDevController.text),
        vwapPeriod: int.parse(_vwapPeriodController.text),
      );
      Navigator.of(context).pop(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Timeframe'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RSI Section
              _buildSectionHeader('RSI'),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _rsiPeriodController,
                      label: 'Period',
                      hint: '9',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNumberField(
                      controller: _rsiOverboughtController,
                      label: 'Overbought',
                      hint: '80',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNumberField(
                      controller: _rsiOversoldController,
                      label: 'Oversold',
                      hint: '20',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Moving Average Section
              _buildSectionHeader('Moving Average'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _emaPeriodsController,
                      label: 'Periods',
                      hint: '9, 50',
                      validator: (value) {
                        if (value == null || _parseEmaPeriods(value).isEmpty) {
                          return 'Enter at least one period';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use SMA',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Switch(
                          value: _useSMA,
                          onChanged: (value) => setState(() => _useSMA = value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // MACD Section
              _buildSectionHeader('MACD'),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _macdFastController,
                      label: 'Fast',
                      hint: '12',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNumberField(
                      controller: _macdSlowController,
                      label: 'Slow',
                      hint: '26',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNumberField(
                      controller: _macdSignalController,
                      label: 'Signal',
                      hint: '9',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bollinger Bands Section
              _buildSectionHeader('Bollinger Bands'),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _bollingerPeriodController,
                      label: 'Period',
                      hint: '20',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDecimalField(
                      controller: _bollingerStdDevController,
                      label: 'Std Dev',
                      hint: '2.0',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // VWAP Section
              _buildSectionHeader('VWAP'),
              _buildNumberField(
                controller: _vwapPeriodController,
                label: 'Period',
                hint: '9',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        final num = int.tryParse(value);
        if (num == null || num <= 0) {
          return 'Invalid';
        }
        return null;
      },
    );
  }

  Widget _buildDecimalField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        final num = double.tryParse(value);
        if (num == null || num <= 0) {
          return 'Invalid';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: validator,
    );
  }
}
