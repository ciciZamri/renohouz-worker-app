import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:renohouz_worker/models/address.dart';
import 'package:renohouz_worker/providers/location_provider.dart';
import 'package:renohouz_worker/widgets/dialog_menu_button.dart';

class AddressFormPage extends StatefulWidget {
  final Address? address;
  const AddressFormPage({Key? key, this.address}) : super(key: key);
  @override
  _AddressFormPageState createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final formKey = GlobalKey<FormState>();
  late LocationProvider locationProvider;
  LocationData? currentLocation;
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription? locationStream;
  bool useManual = false;
  bool isStreaming = false;

  String? currentLocationError;
  double accuracy = 999999.0;

  bool setAsDefault = false;
  TextEditingController streetController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  String state = 'Johor';

  String? streetError;
  String? postcodeError;
  String? areaError;

  void updateCurrentLocation() async {
    bool enabled = await locationProvider.enableLocationService();
    if (!enabled) Navigator.pop(context);
    bool granted = await locationProvider.enableLocationPermission();
    if (!granted) Navigator.pop(context);
    setState(() {
      isStreaming = true;
    });
    locationStream = locationProvider.instance.onLocationChanged.listen((LocationData l) async {
      if (l.accuracy! < accuracy) {
        currentLocation = l;
        accuracy = l.accuracy!;
        final GoogleMapController controller = await mapController.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 17,
        )));
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    if (widget.address != null) {
      currentLocation = LocationData.fromMap({
        'latitude': widget.address!.lat,
        'longitude': widget.address!.long,
      });
      streetController = TextEditingController(text: widget.address!.street);
      postcodeController = TextEditingController(text: widget.address!.postcode);
      areaController = TextEditingController(text: widget.address!.area);
      state = widget.address!.state;
    } else {
      currentLocation = LocationData.fromMap({
        'latitude': 1.8273,
        'longitude': 103.31,
      });
      updateCurrentLocation();
    }
  }

  Widget textField(TextEditingController controller, String label,
      {String? hintText, TextInputType? type, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (val) => val?.isEmpty ?? true ? 'required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (locationStream != null) {
      locationStream?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediaQuery.of(context).viewInsets.bottom > 0
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    'Location pin ${isStreaming ? "(Accuracy: ${accuracy.toStringAsFixed(1)} m)" : ""}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).viewInsets.bottom > 0 ? 2 : 270,
            color: Colors.grey,
            child: GoogleMap(
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId("current-location"),
                  position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  icon: BitmapDescriptor.defaultMarker,
                  draggable: useManual,
                  infoWindow: const InfoWindow(title: 'Location pin'),
                  onDragEnd: useManual
                      ? (pos) {
                          setState(() {
                            currentLocation = LocationData.fromMap({
                              'latitude': pos.latitude,
                              'longitude': pos.longitude,
                            });
                          });
                        }
                      : null,
                ),
              },
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 17,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
            ),
          ),
          currentLocationError == null
              ? const SizedBox(height: 0)
              : Text(currentLocationError!, style: const TextStyle(color: Colors.red)),
          MediaQuery.of(context).viewInsets.bottom > 0
              ? const SizedBox()
              : CheckboxListTile(
                  value: useManual,
                  title: const Text('Set manually'),
                  onChanged: (val) {
                    if (val as bool) {
                      if (locationStream != null) {
                        locationStream?.cancel();
                        setState(() {
                          useManual = true;
                          isStreaming = false;
                        });
                      }
                    } else {
                      setState(() {
                        useManual = false;
                        accuracy = 9999.0;
                      });
                      updateCurrentLocation();
                    }
                  },
                  dense: true,
                ),
          useManual
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Hold and move the pin to set the location manually', style: TextStyle(fontSize: 13)),
                )
              : widget.address != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextButton.icon(
                        onPressed: () {
                          if (locationStream == null) {
                            updateCurrentLocation();
                          }
                        },
                        icon: const Icon(Icons.my_location),
                        label: const Text('Update location'),
                      ),
                    )
                  : const SizedBox(),
          const Divider(thickness: 2),
          Form(
            key: formKey,
            child: Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    const Text('Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: streetController,
                      decoration: InputDecoration(
                        errorText: streetError,
                        labelText: 'Street/House unit',
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    textField(postcodeController, 'Postcode', hintText: '86200', type: TextInputType.number),
                    textField(areaController, 'Area'),
                    DialogMenuButton(
                      label: Text(state),
                      dialogTitle: 'Select state',
                      scrollable: true,
                      dialogContent: [
                        'Johor',
                        'Kedah',
                        'Kelantan',
                        'Kuala Lumpur',
                        'Labuan',
                        'Melaka',
                        'Negeri Sembilan',
                        'Pahang',
                        'Penang',
                        'Perak',
                        'Perlis',
                        'Putrajaya',
                        'Sabah',
                        'Sarawak',
                        'Selangor',
                        'Terengganu'
                      ]
                          .map((e) => InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(child: Text(e)),
                                ),
                                onTap: () => Navigator.pop(context, e),
                              ))
                          .toList(),
                      onSubmitted: (result) => setState(() => state = result),
                      trailIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Set as default', style: TextStyle(fontSize: 14)),
                        value: setAsDefault,
                        onChanged: (val) => setState(() => setAsDefault = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Builder(builder: (context) {
            return Card(
              color: Colors.transparent,
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                width: MediaQuery.of(context).size.width,
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width - 16,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Address address = Address(
                          currentLocation!.latitude!,
                          currentLocation!.longitude!,
                          streetController.text,
                          postcodeController.text,
                          areaController.text,
                          state,
                        );
                        Navigator.pop(context, address);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
