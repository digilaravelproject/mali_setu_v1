import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/transaction_history_controller.dart';
import '../../razorpay/transaction_model.dart';

/*
class TransactionHistoryPage extends GetView<TransactionHistoryController> {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
             margin: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               border: Border.all(color: Colors.grey[200]!)
             ),
             child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
        ),
        title: Text(
          "Transaction History",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTransactions(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.transactions.length + (controller.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.transactions.length) {
                controller.loadMore();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final transaction = controller.transactions[index];
              return _buildTransactionCard(context, transaction);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: context.theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Transactions Yet",
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your payment history will appear here.",
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionItem transaction) {
    final bool isSuccess = transaction.status?.toLowerCase() == 'success';
    final bool isPending = transaction.status?.toLowerCase() == 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPurposeColor(transaction.purpose).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getPurposeIcon(transaction.purpose),
                      color: _getPurposeColor(transaction.purpose),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPurposeTitle(transaction.purpose),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.razorpayOrderId ?? "ID: ${transaction.id}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${transaction.amount}",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: context.theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(transaction.status),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(transaction.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.subscriptionPeriod != null)
                    Text(
                      "${transaction.subscriptionPeriod} Months Validity",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    status = status?.toLowerCase() ?? 'pending';
    Color color = Colors.orange;
    String label = "Pending";
    IconData icon = Icons.timer_outlined;

    if (status == 'success') {
      color = Colors.green;
      label = "Success";
      icon = Icons.check_circle_outline_rounded;
    } else if (status == 'failed') {
      color = Colors.red;
      label = "Failed";
      icon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getPurposeIcon(String? purpose) {
    purpose = purpose?.toLowerCase() ?? "";
    if (purpose.contains("matrimony")) return Icons.favorite_rounded;
    if (purpose.contains("business")) return Icons.business_center_rounded;
    return Icons.payment_rounded;
  }

  Color _getPurposeColor(String? purpose) {
    purpose = purpose?.toLowerCase() ?? "";
    if (purpose.contains("matrimony")) return Colors.pink;
    if (purpose.contains("business")) return Colors.blue;
    return Colors.teal;
  }

  String _getPurposeTitle(String? purpose) {
    purpose = purpose?.toLowerCase() ?? "";
    if (purpose.contains("matrimony")) return "Matrimony Subscription";
    if (purpose.contains("business")) return "Business Registration";
    return "Payment";
  }
}
*/




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/transaction_history_controller.dart';
import '../../razorpay/transaction_model.dart';

class TransactionHistoryPage extends GetView<TransactionHistoryController> {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 22,
              color: Color(0xFF1A1D2E),
            ),
          ),
        ),
        title:  Text(
          "transaction_history".tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF1A1D2E),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A80F0)),
            ),
          );
        }

        if (controller.transactions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTransactions(refresh: true),
          color: const Color(0xFF4A80F0),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: controller.transactions.length + (controller.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.transactions.length) {
                controller.loadMore();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A80F0)),
                    ),
                  ),
                );
              }

              final transaction = controller.transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4A80F0).withOpacity(0.1),
                  const Color(0xFF4A80F0).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 80,
              color: Color(0xFF4A80F0),
            ),
          ),
          const SizedBox(height: 24),
           Text(
            "no_transcation".tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D2E),
              letterSpacing: -0.5,
            ),
          ),
           SizedBox(height: 12),
          Text(
            "no_transcation_msg".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionItem transaction) {
    final bool isSuccess = transaction.status?.toLowerCase() == 'success';
    final bool isPending = transaction.status?.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildPurposeIcon(transaction.purpose),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPurposeTitle(transaction.purpose),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1A1D2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDate(transaction.createdAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${_formatAmount(transaction.amount)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(transaction.status),
                  ],
                ),
              ],
            ),
          ),
          if (transaction.subscriptionPeriod != null) ...[
            Container(
              height: 1,
              color: Colors.grey[100],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A80F0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Color(0xFF4A80F0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Valid for ${transaction.subscriptionPeriod} months",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildPurposeIcon(String? purpose) {
    purpose = purpose?.toLowerCase() ?? "";

    Color color;
    IconData icon;
    Color backgroundColor;

    if (purpose.contains("matrimony")) {
      color = const Color(0xFFE8435F);
      icon = Icons.favorite_rounded;
      backgroundColor = const Color(0xFFE8435F).withOpacity(0.1);
    } else if (purpose.contains("business")) {
      color = const Color(0xFF4A80F0);
      icon = Icons.business_center_rounded;
      backgroundColor = const Color(0xFF4A80F0).withOpacity(0.1);
    } else {
      color = const Color(0xFF00BFA6);
      icon = Icons.payment_rounded;
      backgroundColor = const Color(0xFF00BFA6).withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    status = status?.toLowerCase() ?? 'pending';

    Color color;
    String label;
    IconData icon;
    Color backgroundColor;

    if (status == 'completed') {
      color = const Color(0xFF00BFA6);
      label = "Completed";
      icon = Icons.check_circle_rounded;
      backgroundColor = const Color(0xFF00BFA6).withOpacity(0.1);
    } else if (status == 'failed') {
      color = const Color(0xFFFF5252);
      label = "Failed";
      icon = Icons.cancel_rounded;
      backgroundColor = const Color(0xFFFF5252).withOpacity(0.1);
    } else {
      color = const Color(0xFFFFA726);
      label = "Processing";
      icon = Icons.pending_rounded;
      backgroundColor = const Color(0xFFFFA726).withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Today, ${DateFormat('hh:mm a').format(date)}";
      } else if (difference.inDays == 1) {
        return "Yesterday, ${DateFormat('hh:mm a').format(date)}";
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE, hh:mm a').format(date);
      } else {
        return DateFormat('dd MMM yyyy, hh:mm a').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatAmount(String? amount) {
    if (amount == null) return "0";
    try {
      final num value = num.parse(amount);
      final formatter = NumberFormat('#,##0', 'en_IN');
      return formatter.format(value);
    } catch (e) {
      return amount;
    }
  }

  String _getPurposeTitle(String? purpose) {
    purpose = purpose?.toLowerCase() ?? "";
    if (purpose.contains("matrimony")) return "Matrimony Subscription";
    if (purpose.contains("business")) return "Business Registration";
    return "Payment";
  }
}