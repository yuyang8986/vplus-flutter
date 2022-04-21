class PaymentIntent {
  String paymentIntentId;
  String clientSecret;
  PaymentStatus paymentStatus;

  PaymentIntent({this.paymentIntentId, this.clientSecret, this.paymentStatus});

  PaymentIntent.fromJson(Map<String, dynamic> json) {
    paymentIntentId = json['paymentIntentId'];
    clientSecret = json['clientSecret'];
    paymentStatus = PaymentStatus.values[json['paymentStatus']];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paymentIntentId'] = this.paymentIntentId;
    data['clientSecret'] = this.clientSecret;
    data['paymentStatus'] = this.paymentStatus.index;
    return data;
  }
}

enum PaymentStatus {
  NotStarted,
  InProgress,
  Success,
  Failed,
  Cancelled,
}
