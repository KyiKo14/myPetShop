// lib/Screen/checkout_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // 💡 Uint8List ပေါင်းထည့်ထားသည်
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:mypetshop/Core/Provider/cart_provider.dart';
import 'package:mypetshop/Screen/order_success_screen.dart';
import 'package:mypetshop/Services/cloudinary_service.dart'; // 💡 သင့် Cloudinary Service ကို Import ချိတ်ဆက်လိုက်သည်

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _isPlacingOrder = false;

  XFile? _receiptImage;
  Uint8List? _webImageBytes; // 💡 Flutter Web အတွက် ပုံရွေးချယ်ပြီး Byte Data သိမ်းဆည်းရန်
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _paymentAccounts = {
    'KBZPay': '09-791409559 (U Kyi Zin Ko - KBZPay)',
    'WavePay': '09-791409559 (U Kyi Zin Ko - WavePay)',
    'AYAPay': '09-791409559 (U Kyi Zin Ko - AYAPay)',
    'Credit / Debit Card': 'AYA Bank: 4602-8701-0206-2593 (U Kyi Zin Ko)',
  };

  final List<String> _paymentMethods = [
    'Cash on Delivery', 'KBZPay', 'WavePay', 'AYAPay', 'Credit / Debit Card',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose();
    super.dispose();
  }

  // 💡 ပြေစာဓာတ်ပုံ ရွေးချယ်ပေးမည့် Function (Web ရော Mobile ပါ အဆင်ပြေအောင် ပြင်ဆင်ပြီး)
  Future<void> _pickReceiptImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          // 💡 Web အတွက်ဖြစ်ပါက Cloudinary သို့ ပို့ရန် bytes အဖြစ် ကြိုဖတ်ထားမည်
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _receiptImage = pickedFile;
          });
        } else {
          setState(() => _receiptImage = pickedFile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_paymentMethod != 'Cash on Delivery' && _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your transfer receipt to proceed! 🙏'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    
    String finalReceiptUrl = ''; // Firestore ထဲ သွားသိမ်းမည့် Cloudinary Web URL အမှန်

    try {
      // 💡 ၁။ Online Payment ဖြစ်ပါက ပုံကို Cloudinary သို့ အရင်တင်မည်
      if (_paymentMethod != 'Cash on Delivery' && _receiptImage != null) {
        String? uploadedUrl;
        if (kIsWeb) {
          uploadedUrl = await CloudinaryService.uploadImage(_webImageBytes); // Web အတွက် bytes ပို့သည်
        } else {
          uploadedUrl = await CloudinaryService.uploadImage(_receiptImage); // Mobile အတွက် file ပို့သည်
        }

        if (uploadedUrl == null) {
          throw Exception("Could not upload receipt image to Cloudinary. Please try again.");
        }
        finalReceiptUrl = uploadedUrl; // 🎯 Cloudinary က ပေးသော secure_url အစစ်ကို ရယူခြင်း
      }

      final cartState = ref.read(cartProvider);
      final user = FirebaseAuth.instance.currentUser;

      // 💡 ၂။ ရလာသော Cloudinary URL ကို အချက်အလက်များနှင့်အတူ Firestore သို့ သိမ်းဆည်းခြင်း
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid ?? 'guest',
        'userEmail': user?.email ?? 'guest',
        'customerName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'paymentMethod': _paymentMethod,
        'receiptUrl': finalReceiptUrl, // 🎯 ဤနေရာတွင် Cloudinary URL ရောက်သွားပါပြီ (Admin မြင်ရမည့်အဓိကသော့ချက်)
        'items': cartState.items.map((item) => {
          'name': item.product.name, 'image': item.product.image,
          'price': item.product.price, 'quantity': item.quantity,
          'category': item.product.category,
        }).toList(),
        'totalAmount': cartState.totalPrice,
        'status': 'Pending', 
        'createdAt': FieldValue.serverTimestamp(),
      });

      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
            (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('Delivery Information'),
            const SizedBox(height: 12),
            _field(_nameCtrl, 'Full Name', Icons.person_outline, 'Please enter your name'),
            const SizedBox(height: 12),
            _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined, 'Please enter your phone'),
            const SizedBox(height: 12),
            _field(_addressCtrl, 'Delivery Address', Icons.location_on_outlined, 'Please enter your address'),
            const SizedBox(height: 12),
            _field(_cityCtrl, 'City', Icons.location_city_outlined, 'Required'),
            const SizedBox(height: 24),
            
            _section('Payment Method'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(children: _paymentMethods.map((m) => RadioListTile<String>(
                value: m, groupValue: _paymentMethod,
                onChanged: (v) => setState(() {
                  _paymentMethod = v!;
                  _receiptImage = null; 
                  _webImageBytes = null; // 💡 Reset bytes
                }),
                title: Text(m, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                activeColor: Colors.deepPurple,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              )).toList()),
            ),
            const SizedBox(height: 16),

            // ==================== DYNAMIC ACCOUNT DISPLAY & RECEIPT UPLOAD ====================
            if (_paymentMethod != 'Cash on Delivery') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.deepPurple),
                        const SizedBox(width: 6),
                        Text(
                          'Transfer Money to:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _paymentAccounts[_paymentMethod] ?? '',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const Divider(height: 24),
                    const Text('Upload Transfer Receipt:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
                    const SizedBox(height: 10),
                    
                    InkWell(
                      onTap: _pickReceiptImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: _receiptImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.grey.shade400),
                                  const SizedBox(height: 6),
                                  Text('Click to upload receipt photo', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: kIsWeb
                                    ? (_webImageBytes != null 
                                        ? Image.memory(_webImageBytes!, fit: BoxFit.cover) // 💡 Web ပေါ်တွင် Preview ပြရန် Memory Image ကိုသုံးရမည်
                                        : const SizedBox())
                                    : Image.file(File(_receiptImage!.path), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            _section('Order Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(children: [
                ...cartState.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text('${item.product.name} x${item.quantity}',
                        style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                    Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ]),
                )),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text('\$${cartState.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ]),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Delivery Fee', style: TextStyle(fontSize: 14)),
                  Text('Free', style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('\$${cartState.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                ]),
              ]),
            ),
            const SizedBox(height: 80),
          ]),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))]),
        child: SizedBox(height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            onPressed: _isPlacingOrder ? null : _placeOrder,
            child: _isPlacingOrder
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(_paymentMethod == 'Cash on Delivery' ? 'Place Order • \$${cartState.totalPrice.toStringAsFixed(2)}' : 'Submit & Place Order',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  Widget _field(TextEditingController ctrl, String hint, IconData icon, String error) => TextFormField(
    controller: ctrl,
    validator: (v) => (v == null || v.isEmpty) ? error : null,
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
    ),
  );
}