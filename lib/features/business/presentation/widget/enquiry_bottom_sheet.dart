import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_cluezer/core/constent/api_constants.dart';
import 'package:edu_cluezer/core/controllers/support_controller.dart';
import 'package:edu_cluezer/widgets/custom_image_view.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';

class EnquiryBottomSheet extends StatefulWidget {
  final String itemName;
  final String itemType; // 'Product' or 'Service'
  final String? itemPrice;
  final String? imagePath;
  final String? businessName;
  final String? contactPhone;
  final String? contactEmail;

  const EnquiryBottomSheet({
    Key? key,
    required this.itemName,
    required this.itemType,
    this.itemPrice,
    this.imagePath,
    this.businessName,
    this.contactPhone,
    this.contactEmail,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String itemName,
    required String itemType,
    String? itemPrice,
    String? imagePath,
    String? businessName,
    String? contactPhone,
    String? contactEmail,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnquiryBottomSheet(
        itemName: itemName,
        itemType: itemType,
        itemPrice: itemPrice,
        imagePath: imagePath,
        businessName: businessName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
      ),
    );
  }

  @override
  State<EnquiryBottomSheet> createState() => _EnquiryBottomSheetState();
}

class _EnquiryBottomSheetState extends State<EnquiryBottomSheet> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final store = widget.businessName?.trim().isNotEmpty == true
        ? widget.businessName!.trim()
        : 'your business';
    final priceInfo = widget.itemPrice != null && widget.itemPrice!.trim().isNotEmpty
        ? ' (Price: ₹${widget.itemPrice})'
        : '';
    _messageController = TextEditingController(
      text:
          "Hello, I am interested in inquiring about ${widget.itemType.toLowerCase()} '${widget.itemName}'$priceInfo from $store. Please share more details and availability.",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendWhatsAppEnquiry() async {
    final phone = widget.contactPhone?.trim();
    if (phone == null || phone.isEmpty) {
      CustomSnackBar.showInfo(
        message: 'Contact phone number not available for this seller.',
      );
      return;
    }

    final message = _messageController.text.trim();
    await SupportController.launchWhatsApp(
      phoneNumber: phone,
      message: message.isNotEmpty
          ? message
          : "Hello, I am interested in inquiring about ${widget.itemName}.",
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _makePhoneCall() async {
    final phone = widget.contactPhone?.trim();
    if (phone == null || phone.isEmpty) {
      CustomSnackBar.showInfo(
        message: 'Contact phone number not available.',
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        CustomSnackBar.showError(message: 'Could not launch dialer for $phone');
      }
    } catch (_) {
      CustomSnackBar.showError(message: 'Could not open phone dialer');
    }
  }

  Future<void> _sendEmail() async {
    final email = widget.contactEmail?.trim();
    if (email == null || email.isEmpty) {
      CustomSnackBar.showInfo(
        message: 'Contact email not available.',
      );
      return;
    }

    final message = _messageController.text.trim();
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Enquiry for ${widget.itemName} (${widget.itemType})',
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        CustomSnackBar.showError(message: 'Could not open email app for $email');
      }
    } catch (_) {
      CustomSnackBar.showError(message: 'Could not open email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    String? fullImageUrl;
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      fullImageUrl = widget.imagePath!.startsWith('http')
          ? widget.imagePath!
          : '${ApiConstants.imageBaseUrl}/${widget.imagePath!.replaceFirst(RegExp(r'^/'), '')}';
    }

    final hasPrice = widget.itemPrice != null &&
        widget.itemPrice!.trim().isNotEmpty &&
        widget.itemPrice!.trim().toLowerCase() != 'null';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.help_outline_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.itemType} Enquiry',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Item Preview Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: fullImageUrl != null
                            ? CustomImageView(
                                url: fullImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  widget.itemType == 'Product'
                                      ? Icons.shopping_bag_outlined
                                      : Icons.home_repair_service_outlined,
                                  color: Colors.grey.shade500,
                                ),
                              )
                            : Icon(
                                widget.itemType == 'Product'
                                    ? Icons.shopping_bag_outlined
                                    : Icons.home_repair_service_outlined,
                                color: Colors.grey.shade500,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            if (widget.businessName != null &&
                                widget.businessName!.trim().isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.storefront_outlined,
                                      size: 13, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.businessName!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(
                              hasPrice ? '₹${widget.itemPrice}' : 'Price on request',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: hasPrice
                                    ? const Color(0xFFDC2626)
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Message Input label
                const Text(
                  'Your Enquiry Message',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),

                // Message Text Field
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                  decoration: InputDecoration(
                    hintText: 'Write your enquiry message here...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Primary Action: WhatsApp Enquiry
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _sendWhatsAppEnquiry,
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Enquire on WhatsApp',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // WhatsApp Brand Green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Secondary Actions: Call & Email
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: _makePhoneCall,
                          icon: Icon(Icons.call_outlined, size: 18, color: primaryColor),
                          label: Text(
                            'Call Now',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.contactEmail != null &&
                        widget.contactEmail!.trim().isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _sendEmail,
                            icon: const Icon(Icons.email_outlined,
                                size: 18, color: Color(0xFF4B5563)),
                            label: const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
