import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/real_user_management_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final String userId;

  const SubscriptionScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<SubscriptionTier> _tiers = [];
  bool _isLoading = true;
  bool _isUpgrading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPricingTiers();
  }

  Future<void> _loadPricingTiers() async {
    try {
      final tiers = await RealUserManagementService.getPricingTiers();
      setState(() {
        _tiers = tiers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load pricing tiers from backend: $e');
      // Fall back to static tiers so the screen still works
      setState(() {
        _tiers = SubscriptionTier.allTiers;
        _isLoading = false;
        // Don't show error message, just use fallback data
      });
    }
  }

  Future<void> _upgradeToPlan(SubscriptionTier tier) async {
    setState(() {
      _isUpgrading = true;
      _errorMessage = null;
    });

    try {
      if (tier.name == 'FREE') {
        // Handle downgrade/cancellation
        final result = await RealUserManagementService.cancelSubscription(widget.userId);
        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully cancelled subscription'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          throw Exception(result['error'] ?? 'Failed to cancel subscription');
        }
      } else {
        // Handle upgrade
        final result = await RealUserManagementService.upgradeSubscription(
          userId: widget.userId,
          newTier: tier.name,
          paymentMethod: 'stripe_pm_placeholder', // In production, integrate with payment
        );
        
        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully upgraded to ${tier.name}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          throw Exception(result['error'] ?? 'Failed to upgrade subscription');
        }
      }
    } catch (e) {
      debugPrint('Failed to update subscription: $e');
      setState(() {
        _errorMessage = 'Failed to update subscription: $e';
      });
    } finally {
      setState(() {
        _isUpgrading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _loadPricingTiers();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Choose the perfect plan for your needs',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade or downgrade anytime. No hidden fees.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Pricing cards
          ..._tiers.map((tier) => _buildPricingCard(context, tier)),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, SubscriptionTier tier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tier.isPopular ? Colors.green[400]! : Colors.grey[300]!,
          width: tier.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular badge
          if (tier.isPopular)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: const Text(
                  'MOST POPULAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // Card content
          Container(
            padding: EdgeInsets.all(24).copyWith(
              top: tier.isPopular ? 48 : 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name and price
                Text(
                  tier.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: tier.price == 0 ? 'Free' : '\$${tier.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (tier.price > 0)
                        const TextSpan(
                          text: '/month',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Features
                ...tier.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpgrading ? null : () => _upgradeToPlan(tier),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tier.isPopular ? Colors.green[600] : Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUpgrading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            tier.price == 0 ? 'Get Started Free' : 'Choose ${tier.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
