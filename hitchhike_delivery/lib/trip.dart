import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  String startName, endName, price;
  LatLng startLatlng, endLatlng;
  int id;
  Trip(this.id, this.startName, this.endName, this.startLatlng, this.endLatlng,
      this.price);
}
