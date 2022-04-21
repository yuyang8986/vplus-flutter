import 'package:stripe_payment/stripe_payment.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/models/userPaymentMethod.dart';

class PaymentHelper {
  Future<PaymentMethod> changePaymentMethod() async {
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod = await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod p) {
      print("updated payment method. $p");
      return p;
    }).catchError((e) {
      // print('Errore Card: ${e.toString()}');
      return null;
    });
    return paymentMethod;
  }

  static int convertAmountToCent(double amount) {
    // given a payment amount (measure in dollars) eg: $1.23
    // return it in cents eg: 123

    List<String> splitByDot = amount.toStringAsFixed(2).split('.');
    int amountInt = int.parse(splitByDot[0]);
    int amountDecimal = int.parse(splitByDot[1]);

    return amountInt * 100 + amountDecimal;
  }

  static String showCardInfo(UserPaymentMethod userPaymentMethod) {
    String result = userPaymentMethod.cardBrand.toUpperCase() +
        " - " +
        userPaymentMethod.cardNo;
    return result;
  }
}
