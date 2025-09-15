class SubscriptionTier {
  final String name;
  final double price;
  final int monthlyPageLimit;
  final List<String> features;
  final bool isPopular;

  const SubscriptionTier({
    required this.name,
    required this.price,
    required this.monthlyPageLimit,
    required this.features,
    this.isPopular = false,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      name: json['name'] ?? '',
      price: (json['priceUSD'] ?? 0).toDouble(),
      monthlyPageLimit: json['monthlyPageLimit'] ?? 0,
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['isPopular'] ?? false,
    );
  }

  static const free = SubscriptionTier(
    name: 'FREE',
    price: 0,
    monthlyPageLimit: 10,
    features: ['Basic OCR', '10 pages/month', 'Email support'],
  );

  static const basic = SubscriptionTier(
    name: 'BASIC',
    price: 4.99,
    monthlyPageLimit: 500,
    features: ['Basic OCR', '500 pages/month', 'History tracking', 'Export results', 'Priority support'],
    isPopular: true,
  );

  static const pro = SubscriptionTier(
    name: 'PRO',
    price: 19.99,
    monthlyPageLimit: 2000,
    features: ['Basic OCR', '2000 pages/month', 'History tracking', 'Export results', 'Batch processing', 'API access', '24/7 support'],
  );

  static List<SubscriptionTier> get allTiers => [free, basic, pro];
}

class UserSubscription {
  final String userId;
  final String email;
  final String subscriptionTier;
  final String subscriptionStatus;
  final int monthlyPageLimit;
  final DateTime subscriptionStartDate;
  final DateTime subscriptionEndDate;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscription({
    required this.userId,
    required this.email,
    required this.subscriptionTier,
    required this.subscriptionStatus,
    required this.monthlyPageLimit,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      subscriptionTier: json['subscriptionTier'] ?? 'FREE',
      subscriptionStatus: json['subscriptionStatus'] ?? 'ACTIVE',
      monthlyPageLimit: (json['monthlyPageLimit'] ?? 10).round(), // Convert double to int
      subscriptionStartDate: DateTime.parse(json['subscriptionStartDate']),
      subscriptionEndDate: DateTime.parse(json['subscriptionEndDate']),
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  bool get isActive => subscriptionStatus == 'ACTIVE';
  bool get isPaid => subscriptionTier != 'FREE';
  
  SubscriptionTier get tierInfo {
    switch (subscriptionTier) {
      case 'BASIC':
        return SubscriptionTier.basic;
      case 'PRO':
        return SubscriptionTier.pro;
      default:
        return SubscriptionTier.free;
    }
  }
}

class UsageStats {
  final String userId;
  final String billingPeriod;
  final String subscriptionTier;
  final int totalJobsSubmitted;
  final int totalPagesProcessed;
  final int totalTokensUsed;
  final double totalCostIncurred;
  final int monthlyLimit;
  final int remainingTokens;
  final DateTime? lastJobAt;
  final Map<String, DailyUsage> dailyUsage;
  final DateTime updatedAt;

  UsageStats({
    required this.userId,
    required this.billingPeriod,
    required this.subscriptionTier,
    required this.totalJobsSubmitted,
    required this.totalPagesProcessed,
    required this.totalTokensUsed,
    required this.totalCostIncurred,
    required this.monthlyLimit,
    required this.remainingTokens,
    this.lastJobAt,
    required this.dailyUsage,
    required this.updatedAt,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    final dailyUsageMap = <String, DailyUsage>{};
    final dailyUsageJson = json['dailyUsage'] as Map<String, dynamic>? ?? {};
    
    for (final entry in dailyUsageJson.entries) {
      dailyUsageMap[entry.key] = DailyUsage.fromJson(entry.value);
    }

    return UsageStats(
      userId: json['userId'] ?? '',
      billingPeriod: json['billingPeriod'] ?? '',
      subscriptionTier: json['subscriptionTier'] ?? 'FREE',
      totalJobsSubmitted: (json['totalJobsSubmitted'] ?? 0).round(), // Convert double to int
      totalPagesProcessed: (json['totalPagesProcessed'] ?? 0).round(), // Convert double to int
      totalTokensUsed: (json['totalTokensUsed'] ?? 0).round(), // Convert double to int
      totalCostIncurred: (json['totalCostIncurred'] ?? 0).toDouble(),
      monthlyLimit: (json['monthlyLimit'] ?? 0).round(), // Convert double to int
      remainingTokens: (json['remainingTokens'] ?? 0).round(), // Convert double to int
      lastJobAt: json['lastJobAt'] != null ? DateTime.parse(json['lastJobAt']) : null,
      dailyUsage: dailyUsageMap,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  double get usagePercentage => monthlyLimit > 0 ? (totalTokensUsed / monthlyLimit * 100) : 0;
  
  bool get isNearLimit => usagePercentage >= 75;
  bool get isOverLimit => totalTokensUsed >= monthlyLimit;
  
  String get warningLevel {
    if (usagePercentage >= 90) return 'CRITICAL';
    if (usagePercentage >= 75) return 'HIGH';
    if (usagePercentage >= 50) return 'MEDIUM';
    return 'LOW';
  }
}

class DailyUsage {
  final int jobs;
  final int pages;
  final double cost;

  DailyUsage({
    required this.jobs,
    required this.pages,
    required this.cost,
  });

  factory DailyUsage.fromJson(Map<String, dynamic> json) {
    return DailyUsage(
      jobs: (json['jobs'] ?? 0).round(), // Convert double to int
      pages: (json['pages'] ?? 0).round(), // Convert double to int
      cost: (json['cost'] ?? 0).toDouble(),
    );
  }
}

class UserLimits {
  final int monthlyLimit;
  final int used;
  final int remaining;
  final String tier;
  final double usagePercentage;
  final String warningLevel;
  final String status;

  UserLimits({
    required this.monthlyLimit,
    required this.used,
    required this.remaining,
    required this.tier,
    required this.usagePercentage,
    required this.warningLevel,
    required this.status,
  });

  factory UserLimits.fromJson(Map<String, dynamic> json) {
    return UserLimits(
      monthlyLimit: (json['monthlyLimit'] ?? 0).round(), // Convert double to int
      used: (json['used'] ?? 0).round(), // Convert double to int
      remaining: (json['remaining'] ?? 0).round(), // Convert double to int
      tier: json['tier'] ?? 'FREE',
      usagePercentage: (json['usagePercentage'] ?? 0).toDouble(),
      warningLevel: json['warningLevel'] ?? 'LOW',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  bool get isNearLimit => usagePercentage >= 75;
  bool get isOverLimit => remaining <= 0;
}

class JobRecord {
  final String jobId;
  final String userId;
  final String documentId;
  final String jobType;
  final String status;
  final double estimatedCost;
  final double actualCost;
  final int pagesProcessed;
  final int tokensUsed;
  final int estimatedPages;
  final int fileSize;
  final String fileType;
  final String s3Key;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final String? textractJobId;
  final String billingPeriod;

  JobRecord({
    required this.jobId,
    required this.userId,
    required this.documentId,
    required this.jobType,
    required this.status,
    required this.estimatedCost,
    required this.actualCost,
    required this.pagesProcessed,
    required this.tokensUsed,
    required this.estimatedPages,
    required this.fileSize,
    required this.fileType,
    required this.s3Key,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.textractJobId,
    required this.billingPeriod,
  });

  factory JobRecord.fromJson(Map<String, dynamic> json) {
    return JobRecord(
      jobId: json['jobId'] ?? '',
      userId: json['userId'] ?? '',
      documentId: json['documentId'] ?? '',
      jobType: json['jobType'] ?? 'TEXTRACT_OCR',
      status: json['status'] ?? 'PENDING',
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      actualCost: (json['actualCost'] ?? 0).toDouble(),
      pagesProcessed: (json['pagesProcessed'] ?? 0).round(), // Convert double to int
      tokensUsed: (json['tokensUsed'] ?? 0).round(), // Convert double to int
      estimatedPages: (json['estimatedPages'] ?? 0).round(), // Convert double to int
      fileSize: (json['fileSize'] ?? 0).round(), // Convert double to int
      fileType: json['fileType'] ?? '',
      s3Key: json['s3Key'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      errorMessage: json['errorMessage'],
      textractJobId: json['textractJobId'],
      billingPeriod: json['billingPeriod'] ?? '',
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
  bool get isProcessing => status == 'PROCESSING';

  Duration? get processingTime {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }
}
