class Address {
  late double lat;
  late double long;
  late String street;
  late String postcode;
  late String area;
  late String state;

  Address(this.lat, this.long, this.street, this.postcode, this.area, this.state);

  Address.fromMap(Map details) {
    lat = details['lat'];
    long = details['long'];
    street = details['street'];
    postcode = details['postcode'];
    area = details['area'];
    state = details['state'];
  }

  Map get toMap => {
        'street': street,
        'postcode': postcode,
        'area': area,
        'state': state,
      };

  String get formattedString => '$street,\n$area,\n$postcode $state.';
}
