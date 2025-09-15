import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class UsageTrackingWidget extends StatelessWidget {
  final UserLimits userLimits;
  final bool showDetails;
  final VoidCallback? onUpgradePressed;

  const UsageTrackingWidget({
    super.key,
    required this.userLimits,
    this.showDetails = true,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usage This Month',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _getTextColor(),
                ),
              ),
              if (userLimits.isNearLimit && onUpgradePressed != null)
                TextButton(
                  onPressed: onUpgradePressed,
                  child: const Text('Upgrade'),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${userLimits.used} / ${userLimits.monthlyLimit} pages',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _getTextColor(),
                    ),
                  ),
                  Text(
                    '${userLimits.usagePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getPercentageColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: userLimits.usagePercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              ),
            ],
          ),
          
          if (showDetails) ...[
            const SizedBox(height: 12),
            
            // Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Remaining',
                    '${userLimits.remaining}',
                    Icons.hourglass_empty,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Plan',
                    userLimits.tier,
                    Icons.workspace_premium,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Status',
                    userLimits.status,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
          
          // Warning message
          if (userLimits.isNearLimit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getWarningBackgroundColor(),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    userLimits.isOverLimit ? Icons.error : Icons.warning,
                    color: _getWarningIconColor(),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getWarningMessage(),
                      style: TextStyle(
                        color: _getWarningTextColor(),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _getIconColor(), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _getSecondaryTextColor(),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    if (userLimits.isOverLimit) return Colors.red[50]!;
    if (userLimits.isNearLimit) return Colors.orange[50]!;
    return Colors.green[50]!;
  }

  Color _getBorderColor() {
    if (userLimits.isOverLimit) return Colors.red[200]!;
    if (userLimits.isNearLimit) return Colors.orange[200]!;
    return Colors.green[200]!;
  }

  Color _getTextColor() {
    if (userLimits.isOverLimit) return Colors.red[800]!;
    if (userLimits.isNearLimit) return Colors.orange[800]!;
    return Colors.green[800]!;
  }

  Color _getSecondaryTextColor() {
    if (userLimits.isOverLimit) return Colors.red[600]!;
    if (userLimits.isNearLimit) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  Color _getIconColor() {
    if (userLimits.isOverLimit) return Colors.red[600]!;
    if (userLimits.isNearLimit) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  Color _getProgressColor() {
    if (userLimits.isOverLimit) return Colors.red[400]!;
    if (userLimits.isNearLimit) return Colors.orange[400]!;
    return Colors.green[400]!;
  }

  Color _getPercentageColor() {
    if (userLimits.isOverLimit) return Colors.red[700]!;
    if (userLimits.isNearLimit) return Colors.orange[700]!;
    return Colors.green[700]!;
  }

  Color _getWarningBackgroundColor() {
    if (userLimits.isOverLimit) return Colors.red[100]!;
    return Colors.orange[100]!;
  }

  Color _getWarningIconColor() {
    if (userLimits.isOverLimit) return Colors.red[600]!;
    return Colors.orange[600]!;
  }

  Color _getWarningTextColor() {
    if (userLimits.isOverLimit) return Colors.red[700]!;
    return Colors.orange[700]!;
  }

  String _getWarningMessage() {
    if (userLimits.isOverLimit) {
      return 'You have reached your monthly limit. Upgrade to continue processing documents.';
    }
    return 'You are approaching your monthly limit. Consider upgrading your plan.';
  }
}

/// Compact version for smaller spaces
class CompactUsageWidget extends StatelessWidget {
  final UserLimits userLimits;
  final VoidCallback? onTap;

  const CompactUsageWidget({
    super.key,
    required this.userLimits,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBorderColor()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.donut_small,
              size: 16,
              color: _getIconColor(),
            ),
            const SizedBox(width: 6),
            Text(
              '${userLimits.used}/${userLimits.monthlyLimit}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getTextColor(),
              ),
            ),
            if (userLimits.isNearLimit) ...[
              const SizedBox(width: 4),
              Icon(
                userLimits.isOverLimit ? Icons.error : Icons.warning,
                size: 12,
                color: _getWarningColor(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (userLimits.isOverLimit) return Colors.red[50]!;
    if (userLimits.isNearLimit) return Colors.orange[50]!;
    return Colors.green[50]!;
  }

  Color _getBorderColor() {
    if (userLimits.isOverLimit) return Colors.red[200]!;
    if (userLimits.isNearLimit) return Colors.orange[200]!;
    return Colors.green[200]!;
  }

  Color _getTextColor() {
    if (userLimits.isOverLimit) return Colors.red[700]!;
    if (userLimits.isNearLimit) return Colors.orange[700]!;
    return Colors.green[700]!;
  }

  Color _getIconColor() {
    if (userLimits.isOverLimit) return Colors.red[600]!;
    if (userLimits.isNearLimit) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  Color _getWarningColor() {
    if (userLimits.isOverLimit) return Colors.red[600]!;
    return Colors.orange[600]!;
  }
}
