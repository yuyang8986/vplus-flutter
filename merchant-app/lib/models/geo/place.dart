class Place {
  String streetNumber;
  String street;
  String city;
  String state;
  String zipCode;
  double lat;
  double lng;

  Place(
      {this.streetNumber,
      this.street,
      this.city,
      this.state,
      this.zipCode,
      this.lat,
      this.lng});

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, state: $state, zipCode: $zipCode)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
