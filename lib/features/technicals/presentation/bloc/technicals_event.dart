part of 'technicals_bloc.dart';

/// Base class for all technicals events.
sealed class TechnicalsEvent extends Equatable {
  const TechnicalsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select a watchlist.
final class SelectWatchlist extends TechnicalsEvent {
  final Watchlist watchlist;

  const SelectWatchlist(this.watchlist);

  @override
  List<Object?> get props => [watchlist];
}

/// Event to select a timeframe configuration.
final class SelectTimeframe extends TechnicalsEvent {
  final TimeframeConfig timeframe;

  const SelectTimeframe(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}

/// Event to select a specific date.
final class SelectDate extends TechnicalsEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Event to navigate date backwards by one day.
final class NavigateDateBack extends TechnicalsEvent {
  const NavigateDateBack();
}

/// Event to navigate date forwards by one day.
final class NavigateDateForward extends TechnicalsEvent {
  const NavigateDateForward();
}

/// Event to expand a symbol's details.
final class ExpandSymbol extends TechnicalsEvent {
  final String symbol;

  const ExpandSymbol(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Event to collapse expanded symbol details.
final class CollapseSymbol extends TechnicalsEvent {
  const CollapseSymbol();
}

/// Event to update the list of available watchlists.
final class UpdateAvailableWatchlists extends TechnicalsEvent {
  final List<Watchlist> watchlists;

  const UpdateAvailableWatchlists(this.watchlists);

  @override
  List<Object?> get props => [watchlists];
}

/// Event to load technical indicators for a symbol.
final class LoadTechnicals extends TechnicalsEvent {
  final String symbol;

  const LoadTechnicals(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Event to clear technical calculation error.
final class ClearTechnicalsError extends TechnicalsEvent {
  const ClearTechnicalsError();
}

/// Event to load fundamentals data for a symbol.
final class LoadFundamentals extends TechnicalsEvent {
  final String symbol;

  const LoadFundamentals(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Event to sync AV mode setting from Hive into BLoC state.
final class SyncAvMode extends TechnicalsEvent {
  const SyncAvMode();
}
