// ================================================================
// Notifications Screen
// Allin1 Super App - Allin1
// ================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kSurface = Color(0xFF0D0D18);
const Color kCard = Color(0xFF141420);
const Color kCard2 = Color(0xFF1A1A28);
const Color kPurple = Color(0xFF7B6FE0);
const Color kGreen = Color(0xFF3DBA6F);
const Color kGold = Color(0xFFF5C542);
const Color kOrange = Color(0xFFE07C6F);
const Color kRed = Color(0xFFE05555);
const Color kText = Color(0xFFEEEEF5);
const Color kMuted = Color(0xFF7777A0);
const Color kBorder = Color(0x267B6FE0);

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          'Notifications',
          style: GoogleFonts.outfit(color: kText, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(context, user?.uid),
            child:
                Text('Mark all read', style: GoogleFonts.outfit(color: kGold)),
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Text(
                'Please login',
                style: GoogleFonts.outfit(color: kMuted),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kGold),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data()! as Map<String, dynamic>;
                    return _buildNotificationItem(context, data, doc.id);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none, color: kMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: GoogleFonts.outfit(color: kText, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: GoogleFonts.outfit(color: kMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final type = data['type'] as String? ?? 'promo';
    final title = data['title'] as String? ?? '';
    final message = data['message'] as String? ?? '';
    final isRead = data['read'] as bool? ?? false;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isRead ? kCard : kCard2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _markAsRead(context, docId),
          onLongPress: () => _showDeleteDialog(context, docId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: kText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: GoogleFonts.outfit(
                          color: kMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(createdAt),
                          style: GoogleFonts.outfit(
                            color: kMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kGold,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'ride_accepted':
        icon = Icons.directions_bike;
        color = kGold;
        break;
      case 'ride_completed':
        icon = Icons.check_circle;
        color = kGreen;
        break;
      case 'order_accepted':
        icon = Icons.inventory_2;
        color = kPurple;
        break;
      case 'order_delivered':
        icon = Icons.rocket_launch;
        color = kGreen;
        break;
      case 'payment':
        icon = Icons.currency_rupee;
        color = kGold;
        break;
      default:
        icon = Icons.celebration;
        color = kOrange;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _markAsRead(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }

  Future<void> _markAllRead(BuildContext context, String? userId) async {
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All notifications marked as read',
            style: GoogleFonts.notoSansTamil(color: Colors.white),
          ),
          backgroundColor: kGreen,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard2,
        title: Text('Delete?', style: GoogleFonts.outfit(color: kText)),
        content: Text(
          'Remove this notification?',
          style: GoogleFonts.outfit(color: kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: kMuted)),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(docId)
                  .delete();
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: GoogleFonts.outfit(color: kRed)),
          ),
        ],
      ),
    );
  }
}
