import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/api_key_tile.dart';

/// Settings page for app configuration
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsBloc>()..add(const LoadSettings()),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              // App Info Section
              _buildAppInfoSection(theme),

              const Divider(height: 32),

              // API Configuration Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'API Configuration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Configure API keys to enable market data features',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Finnhub API Key
              ApiKeyTile(
                provider: ApiProvider.finnhub,
                configured: state.finnhubConfigured,
                onConfigure: () => _showApiKeyDialog(
                  context,
                  ApiProvider.finnhub,
                  state.finnhubConfigured,
                ),
              ),

              // MarketAux API Key
              ApiKeyTile(
                provider: ApiProvider.marketaux,
                configured: state.marketauxConfigured,
                onConfigure: () => _showApiKeyDialog(
                  context,
                  ApiProvider.marketaux,
                  state.marketauxConfigured,
                ),
              ),

              // Alpha Vantage API Key
              ApiKeyTile(
                provider: ApiProvider.alphaVantage,
                configured: state.alphaVantageConfigured,
                onConfigure: () => _showApiKeyDialog(
                  context,
                  ApiProvider.alphaVantage,
                  state.alphaVantageConfigured,
                ),
              ),

              // Alpha Vantage Technicals Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('Use Alpha Vantage for Technicals'),
                  subtitle: const Text(
                    'Server-side RSI, EMA, MACD, Bollinger (uses API calls)',
                  ),
                  value: state.useAvForTechnicals,
                  onChanged: state.alphaVantageConfigured
                      ? (value) {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleAvForTechnicals(enabled: value));
                        }
                      : null,
                  secondary: Icon(
                    Icons.cloud_outlined,
                    color: state.alphaVantageConfigured ? null : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Configuration status summary
              _buildConfigurationStatus(context, state),

              const Divider(height: 32),

              // About Section
              _buildAboutSection(theme),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppInfoSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.candlestick_chart,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watchlist Technicals',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationStatus(BuildContext context, SettingsState state) {
    final theme = Theme.of(context);
    final configuredCount = state.configuredCount;
    final totalCount = ApiProvider.values.length;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (state.allConfigured) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'All APIs configured';
    } else if (configuredCount > 0) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = '$configuredCount of $totalCount APIs configured';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = 'No APIs configured';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _darken(statusColor),
                  ),
                ),
                if (!state.allConfigured) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Some features may be unavailable',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Data Sources'),
          subtitle: const Text('Finnhub, MarketAux, Yahoo Finance, Alpha Vantage'),
          onTap: () {
            // Could show a dialog with more details
          },
        ),
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: const Text('Local Storage'),
          subtitle: const Text('Watchlists and cache stored locally'),
          onTap: () {
            // Could show cache management options
          },
        ),
      ],
    );
  }

  void _showApiKeyDialog(
    BuildContext context,
    ApiProvider provider,
    bool isConfigured,
  ) {
    ApiKeyDialog.show(
      context,
      provider: provider,
      isConfigured: isConfigured,
    );
  }
}
