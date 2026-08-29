import 'package:url_launcher/url_launcher.dart';

enum PaymentMethod {
  upi,
  stripeCard,
  paypal,
}

class PaymentGatewayService {
  /// Launches UPI Deep-Link Payment (Google Pay, PhonePe, Paytm, BHIM)
  static Future<bool> launchUpiPayment({
    required String payeeName,
    required String upiId,
    required double amount,
    required String note,
  }) async {
    final Uri upiUri = Uri.parse(
      'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(note)}',
    );

    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback web URL launch for testing environment
        final Uri fallbackUri = Uri.parse(
          'https://paytm.com/pay-option?pa=$upiId&am=${amount.toStringAsFixed(2)}',
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// Launches Stripe Secure Web Checkout
  static Future<bool> launchStripeCheckout({
    required double amount,
    required String description,
  }) async {
    // Stripe test checkout gateway link
    final Uri stripeUri = Uri.parse(
      'https://checkout.stripe.com/pay/cs_test_${amount.toStringAsFixed(0)}',
    );

    try {
      await launchUrl(stripeUri, mode: LaunchMode.externalApplication);
      return true;
    } catch (_) {
      return false;
    }
  }
}
