import 'package:flutter/material.dart';
import '../../core/theme/admin_theme.dart';

/// Stat card showing a live metric with icon, value, label and optional trend.
class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend; // e.g. "+12%"
  final bool isLoading;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AdminTheme.saffron,
    this.trend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: isLoading
          ? _buildShimmer()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const Spacer(),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: trend!.startsWith('+')
                              ? AdminTheme.success.withValues(alpha: 0.1)
                              : AdminTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trend!.startsWith('+')
                                ? AdminTheme.success
                                : AdminTheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AdminTheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 28,
          decoration: BoxDecoration(
            color: AdminTheme.background,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 14,
          decoration: BoxDecoration(
            color: AdminTheme.background,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
