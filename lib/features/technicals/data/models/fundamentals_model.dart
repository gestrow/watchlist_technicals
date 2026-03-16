class CompanyOverviewModel {
  final String symbol;
  final String name;
  final String description;
  final String sector;
  final String industry;
  final String marketCap;
  final String peRatio;
  final String dividendYield;
  final String weekHigh52;
  final String weekLow52;
  final String eps;
  final String beta;

  const CompanyOverviewModel({
    required this.symbol,
    required this.name,
    required this.description,
    required this.sector,
    required this.industry,
    required this.marketCap,
    required this.peRatio,
    required this.dividendYield,
    required this.weekHigh52,
    required this.weekLow52,
    required this.eps,
    required this.beta,
  });

  factory CompanyOverviewModel.fromJson(Map<String, dynamic> json) {
    return CompanyOverviewModel(
      symbol: json['Symbol'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      sector: json['Sector'] as String? ?? '',
      industry: json['Industry'] as String? ?? '',
      marketCap: json['MarketCapitalization'] as String? ?? '0',
      peRatio: json['PERatio'] as String? ?? 'None',
      dividendYield: json['DividendYield'] as String? ?? 'None',
      weekHigh52: json['52WeekHigh'] as String? ?? '0',
      weekLow52: json['52WeekLow'] as String? ?? '0',
      eps: json['EPS'] as String? ?? 'None',
      beta: json['Beta'] as String? ?? 'None',
    );
  }

  Map<String, dynamic> toJson() => {
        'Symbol': symbol,
        'Name': name,
        'Description': description,
        'Sector': sector,
        'Industry': industry,
        'MarketCapitalization': marketCap,
        'PERatio': peRatio,
        'DividendYield': dividendYield,
        '52WeekHigh': weekHigh52,
        '52WeekLow': weekLow52,
        'EPS': eps,
        'Beta': beta,
      };
}

class EarningsQuarterModel {
  final String fiscalDateEnding;
  final String reportedEPS;
  final String estimatedEPS;
  final String surprise;
  final String surprisePercentage;

  const EarningsQuarterModel({
    required this.fiscalDateEnding,
    required this.reportedEPS,
    required this.estimatedEPS,
    required this.surprise,
    required this.surprisePercentage,
  });

  factory EarningsQuarterModel.fromJson(Map<String, dynamic> json) {
    return EarningsQuarterModel(
      fiscalDateEnding: json['fiscalDateEnding'] as String? ?? '',
      reportedEPS: json['reportedEPS'] as String? ?? 'None',
      estimatedEPS: json['estimatedEPS'] as String? ?? 'None',
      surprise: json['surprise'] as String? ?? '0',
      surprisePercentage: json['surprisePercentage'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'fiscalDateEnding': fiscalDateEnding,
        'reportedEPS': reportedEPS,
        'estimatedEPS': estimatedEPS,
        'surprise': surprise,
        'surprisePercentage': surprisePercentage,
      };
}

class IncomeQuarterModel {
  final String fiscalDateEnding;
  final String totalRevenue;
  final String grossProfit;
  final String netIncome;

  const IncomeQuarterModel({
    required this.fiscalDateEnding,
    required this.totalRevenue,
    required this.grossProfit,
    required this.netIncome,
  });

  factory IncomeQuarterModel.fromJson(Map<String, dynamic> json) {
    return IncomeQuarterModel(
      fiscalDateEnding: json['fiscalDateEnding'] as String? ?? '',
      totalRevenue: json['totalRevenue'] as String? ?? '0',
      grossProfit: json['grossProfit'] as String? ?? '0',
      netIncome: json['netIncome'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'fiscalDateEnding': fiscalDateEnding,
        'totalRevenue': totalRevenue,
        'grossProfit': grossProfit,
        'netIncome': netIncome,
      };
}
