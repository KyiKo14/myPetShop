// lib/role_based_login/Admin/admin_orders_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed':
      case 'approved': return Colors.blue;
      case 'shipped': return Colors.deepPurple;
      case 'delivered':
      case 'success': return Colors.green;
      case 'cancelled':
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  // 💡 Status ပြောင်းလဲပေးမည့် Function
  Future<void> _updateStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order updated to $newStatus successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 💡 ပြေစာပုံကြီး ချဲ့ကြည့်ရန် Dialog Box
  void _showReceiptDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Transfer Receipt', style: TextStyle(fontSize: 16)),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ),
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: kIsWeb ? Image.network(path, fit: BoxFit.contain) : Image.file(File(path), fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Customer Orders', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 💡 ဆိုင်ရှိ အော်ဒါအားလုံးကို ဆွဲထုတ်ခြင်း
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final docs = snapshot.data?.docs ?? [];
          
          // ရက်စွဲအလိုက် အသစ်ဆုံးကို ထိပ်ဆုံးပို့ရန် Sorting စီခြင်း
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
          sortedDocs.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          if (sortedDocs.isEmpty) {
            return const Center(child: Text('No orders received yet.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final docId = sortedDocs[index].id;
              final data = sortedDocs[index].data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
              final status = data['status'] ?? 'Pending';
              final total = data['totalAmount'] ?? 0;
              final paymentMethod = data['paymentMethod'] ?? 'Cash on Delivery';
              final receiptUrl = data['receiptUrl'] ?? '';
              final createdAt = data['createdAt'] as Timestamp?;
              
              final dateStr = createdAt != null 
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt.toDate()) 
                  : 'Just now';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.all(16),
                  title: Text('Customer: ${data['customerName'] ?? 'Guest'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $dateStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ],
                      )
                    ],
                  ),
                  children: [
                    const Divider(),
                    // --- ဝယ်ယူထားသည့် ပစ္စည်းများစာရင်း ---
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item['name']} x${item['quantity']}', style: const TextStyle(fontSize: 13))),
                          Text('\$${(item['price'] * item['quantity']).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                    const Divider(),
                    // --- ပို့ဆောင်ရမည့်လိပ်စာနှင့် ဖုန်း ---
                    _infoRow(Icons.phone, 'Phone: ${data['phone'] ?? ''}'),
                    _infoRow(Icons.location_on_outlined, 'Address: ${data['address'] ?? ''}, ${data['city'] ?? ''}'),
                    _infoRow(Icons.payment, 'Payment: $paymentMethod'),
                    
                    // --- ငွေလွှဲပြေစာပုံ ရှိပါက ပြရန်ခလုတ် ---
                    if (receiptUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showReceiptDialog(context, receiptUrl),
                        icon: const Icon(Icons.image_search_rounded, size: 18),
                        label: const Text('View Transfer Receipt', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple, side: const BorderSide(color: Colors.deepPurple)),
                      ),
                    ],
                    const Divider(height: 24),
                    // --- Admin Action Buttons (အခြေအနေ ပြောင်းလဲရန် ခလုတ်များ) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status.toLowerCase() == 'pending') ...[
                          TextButton(
                            onPressed: () => _updateStatus(context, docId, 'Cancelled'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updateStatus(context, docId, 'Confirmed'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, elevation: 0),
                            child: const Text('Confirm Order', style: TextStyle(color: Colors.white)),
                          ),
                        ] else if (status.toLowerCase() == 'confirmed') ...[
                          ElevatedButton(
                            onPressed: () => _updateStatus(context, docId, 'Shipped'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, elevation: 0),
                            child: const Text('Mark as Shipped', style: TextStyle(color: Colors.white)),
                          ),
                        ] else if (status.toLowerCase() == 'shipped') ...[
                          ElevatedButton(
                            onPressed: () => _updateStatus(context, docId, 'Delivered'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0),
                            child: const Text('Mark as Delivered', style: TextStyle(color: Colors.white)),
                          ),
                        ] else ...[
                          Text('Order Completed ✨', style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontSize: 13)),
                        ]
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black))),
      ],
    ),
  );
}