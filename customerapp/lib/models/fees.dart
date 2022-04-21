import 'dart:convert';

Fees feesFromJson(String str) => Fees.fromJson(json.decode(str));

String feesToJson(Fees data) => json.encode(data.toJson());

class Fees {
    Fees({
        this.feesId,
        this.name,
        this.description,
        this.feesType,
        this.fixedAmount,
        this.discount,
        this.percentageAmount,
        this.discountMinRequired,
        this.discountMinSpend,
    });

    int feesId;
    String name;
    String description;
    int feesType;
    double fixedAmount;
    double discount;
    double percentageAmount;
    bool discountMinRequired;
    double discountMinSpend;

    factory Fees.fromJson(Map<String, dynamic> json) => Fees(
        feesId: json["feesId"],
        name: json["name"],
        description: json["description"],
        feesType: json["feesType"],
        fixedAmount: json["fixedAmount"],
        discount: json["discount"],
        percentageAmount: json["percentageAmount"],
        discountMinRequired: json["discountMinRequired"],
        discountMinSpend: json["discountMinSpend"],
    );

    Map<String, dynamic> toJson() => {
        "feesId": feesId,
        "name": name,
        "description": description,
        "feesType": feesType,
        "fixedAmount": fixedAmount,
        "discount": discount,
        "percentageAmount": percentageAmount,
        "discountMinRequired": discountMinRequired,
        "discountMinSpend": discountMinSpend,
    };
}