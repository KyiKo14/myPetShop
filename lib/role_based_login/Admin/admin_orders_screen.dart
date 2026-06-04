// lib/role_based_login/Admin/admin_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; 

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

  Future<void> _updateStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated to $newStatus successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 💡 🎯 စနစ်သစ်- Firestore ထဲမှ အော်ဒါအား အပြီးတိုင်ဖျက်ပစ်မည့် Function
  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted permanently! 🗑️'), 
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete order: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showReceiptDialog(BuildContext context, String urlPath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Transfer Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black), 
                  onPressed: () => Navigator.pop(context)
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    urlPath, 
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: CircularProgressIndicator(color: Colors.deepPurple),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("❌ Failed to load receipt image from Cloudinary."),
                      );
                    },
                  ),
                ),
              ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Customer Orders', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders received yet.', style: TextStyle(color: Colors.grey)));
          }

          final sortedDocs = snapshot.data!.docs;

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
              final locationUrl = data['locationUrl'] ?? ''; 
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
                  
                  // 🎯 ကြီးမားသော ပြင်ဆင်ချက်- ExpansionTile ၏ ညာဘက်အစွန်းတွင် အော်ဒါဖျက်နိုင်မည့် အမှိုက်ပုံး ခလုတ် ထည့်သွင်းခြင်း
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete Order?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          content: const Text('Are you sure you want to delete this order permanently from database?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _deleteOrder(context, docId); // 🗑️ ဖျက်မည့် Function သို့ လှမ်းပို့ခြင်း
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
                              child: const Text('Delete', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
                          const SizedBox(width: 10),
                          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  children: [
                    const Divider(),
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
                    _infoRow(Icons.phone, 'Phone: ${data['phone'] ?? ''}'),
                    _infoRow(Icons.location_on_outlined, 'Address: ${data['address'] ?? ''}, ${data['city'] ?? ''}'),
                    _infoRow(Icons.payment, 'Payment: $paymentMethod'),
                    
                    if (locationUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () async {
                            final Uri url = Uri.parse(locationUrl);
                            try {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Could not open map: $e")),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.map_rounded, color: Colors.green, size: 18),
                          label: const Text('Open Customer Location on Map', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.08),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],

                    if (receiptUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showReceiptDialog(context, receiptUrl),
                          icon: const Icon(Icons.image_search_rounded, size: 18),
                          label: const Text('View Transfer Receipt', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple, 
                            side: const BorderSide(color: Colors.deepPurple, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                    const Divider(height: 24),
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