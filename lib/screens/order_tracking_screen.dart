// ================================================================
// Order Tracking Screen
// Allin1 Super App - Allin1
// ================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kSurface = Color(0xFF0D0D18);
const Color kCard = Color(0xFF141420);
const Color kCard2 = Color(0xFF1A1A28);
const Color kPurple = Color(0xFF7B6FE0);
const Color kGreen = Color(0xFF3DBA6F);
const Color kGold = Color(0xFFF5C542);
const Color kRed = Color(0xFFE05555);
const Color kOrange = Color(0xFFE07C6F);
const Color kText = Color(0xFFEEEEF5);
const Color kMuted = Color(0xFF7777A0);
const Color kBorder = Color(0x267B6FE0);

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({required this.orderId, super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('orderId', orderId));
  }
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Tracking',
          style: GoogleFonts.outfit(color: kText, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kGold),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Order not found',
                style: GoogleFonts.outfit(color: kMuted),
              ),
            );
          }

          final order = snapshot.data!.data()! as Map<String, dynamic>;
          return _buildContent(order, context);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> order, BuildContext context) {
    final status = order['status'] as String? ?? 'pending';
    final paymentStatus = order['paymentStatus'] as String? ?? 'pending';
    final items = order['items'] as List<dynamic>? ?? [];
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final address = order['deliveryAddress'] as String? ?? '';
    final estimatedTime = order['estimatedTime'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(status),
          const SizedBox(height: 24),
          _buildOrderDetails(items, total, address, estimatedTime),
          const SizedBox(height: 20),
          _buildActionButtons(status, paymentStatus, total, context),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String status) {
    final stages = ['placed', 'accepted', 'ontheway', 'delivered'];
    final currentIndex = stages.indexOf(status);
    final labels = ['Order Placed', 'Accepted', 'On the Way', 'Delivered'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isCompleted = index <= currentIndex;
              final isActive = index == currentIndex;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? kGreen : kCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isActive ? kGold : (isCompleted ? kGreen : kMuted),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : (isActive
                            ? Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: kGold,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[index],
                    style: GoogleFonts.outfit(
                      color: isCompleted ? kText : kMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }),
          ),
          // Progress line
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              final isFilled = index < currentIndex;
              return Expanded(
                child: Container(
                  height: 3,
                  color: isFilled ? kGreen : kBorder,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(
    List<dynamic> items,
    double total,
    String address,
    String estimatedTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER DETAILS',
            style: GoogleFonts.outfit(
              color: kMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Items
          ...items.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    itemMap['emoji']?.toString() ?? '📦',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${itemMap['name']} x${itemMap['quantity']}',
                      style: GoogleFonts.outfit(color: kText, fontSize: 14),
                    ),
                  ),
                  Text(
                    '₹${(itemMap['price'] as num).toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(color: kText),
                  ),
                ],
              ),
            );
          }),

          const Divider(color: kBorder),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.outfit(
                  color: kText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Address
          if (address.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: kMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: GoogleFonts.outfit(color: kMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Estimated time
          if (estimatedTime.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.access_time, color: kMuted, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Estimated: $estimatedTime',
                  style: GoogleFonts.outfit(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    String status,
    String paymentStatus,
    double total,
    BuildContext context,
  ) {
    return Column(
      children: [
        // Cancel button (only if pending)
        if (status == 'pending')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelOrder,
              style: OutlinedButton.styleFrom(
                foregroundColor: kRed,
                side: const BorderSide(color: kRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Cancel Order',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ),

        if (status == 'pending') const SizedBox(height: 12),

        // Contact vendor
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _contactVendor,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Vendor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        // Pay Now button (if delivered but not paid)
        if (status == 'delivered' && paymentStatus != 'paid') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/payment',
                arguments: total,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Pay Now • ₹${total.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard2,
        title: Text('Cancel Order?', style: GoogleFonts.outfit(color: kText)),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: GoogleFonts.outfit(color: kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: GoogleFonts.outfit(color: kMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Cancel', style: GoogleFonts.outfit(color: kRed)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': 'cancelled'});

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _contactVendor() async {
    final waUrl = Uri.parse('https://wa.me/918681869091');
    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    }
  }
}
