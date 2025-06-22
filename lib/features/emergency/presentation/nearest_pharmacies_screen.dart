import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:latlong2/latlong.dart';
import 'package:littlesteps/features/emergency/providers/emergency_provider.dart';
import 'package:littlesteps/shared/widgets/location_service.dart';
import 'package:littlesteps/shared/widgets/distance_calculator.dart' as my_utils;
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io' show Platform;
import 'package:littlesteps/gen_l10n/app_localizations.dart';

class NearestPharmaciesScreen extends ConsumerStatefulWidget {
  const NearestPharmaciesScreen({super.key});

  @override
  ConsumerState<NearestPharmaciesScreen> createState() =>
      _NearestPharmaciesScreenState();
}

class _NearestPharmaciesScreenState extends ConsumerState<NearestPharmaciesScreen> {
  double? userLat;
  double? userLon;
  String? userAddress;
  bool locationError = false;

  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      locationError = false;
      userAddress = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      userLat = position?.latitude;
      userLon = position?.longitude;

      if (userLat != null && userLon != null) {
        final placemarks =
            await geocoding.placemarkFromCoordinates(userLat!, userLon!);
        final place = placemarks.first;
        setState(() {
          userAddress = "${place.locality}, ${place.country}";
        });
        ref.refresh(emergencyPharmaciesProvider((userLat!, userLon!)));
      }
    } catch (e) {
      setState(() => locationError = true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.locationErrorMessage)),
        );
      }
    }
  }

  Future<void> _openMapApp(BuildContext context, double lat, double lon) async {
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull('geo:$lat,$lon?q=$lat,$lon(Pharmacy)'),
          package: 'com.google.android.apps.maps',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        return;
      }

      final mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        return;
      }

      throw 'No map app found';
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.openMapError)),
        );
      }
    }
  }

  Future<void> _startNavigation(BuildContext context, double lat, double lon) async {
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull('google.navigation:q=$lat,$lon&mode=d'),
          package: 'com.google.android.apps.maps',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        return;
      }

      final mapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving');
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        return;
      }

      throw 'No map app found';
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.startNavError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final pharmacyData =
        ref.watch(emergencyPharmaciesProvider((userLat ?? 0, userLon ?? 0)));

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.nearestPharmaciesTitle),
        actions: [
          IconButton(
            onPressed: _initLocation,
            icon: const Icon(Icons.refresh),
            tooltip: tr.locationRefreshTooltip,
          ),
        ],
      ),
      body: locationError
          ? Center(child: Text(tr.locationErrorMessage))
          : userLat == null || userLon == null
              ? Center(child: Text(tr.locationLoading))
              : pharmacyData.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("❌ $e")),
                  data: (pharmacies) {
                    final enriched = pharmacies.map((p) {
                      final lat = double.tryParse(p["lat"].toString()) ?? 0.0;
                      final lon = double.tryParse(p["lon"].toString()) ?? 0.0;
                      final distance = my_utils.DistanceCalculator
                          .calculateDistance(userLat!, userLon!, lat, lon);
                      return {
                        ...p,
                        "lat": lat,
                        "lon": lon,
                        "distance": distance,
                      };
                    }).toList()
                      ..sort((a, b) => a["distance"].compareTo(b["distance"]));

                    return Column(
                      children: [
                        if (userAddress != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tr.currentLocationLabel(userAddress!),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        SizedBox(
                          height: 200,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(userLat!, userLon!),
                              initialZoom: 13,
                              onTap: (_, __) => _popupController.hideAllPopups(),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              ),
                              PopupMarkerLayer(
                                options: PopupMarkerLayerOptions(
                                  popupController: _popupController,
                                  markers: [
                                    Marker(
                                      point: LatLng(userLat!, userLon!),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                                    ),
                                    ...enriched.map(
                                      (p) => Marker(
                                        point: LatLng(p["lat"], p["lon"]),
                                        width: 30,
                                        height: 30,
                                        child: const Icon(Icons.local_pharmacy, color: Colors.green),
                                      ),
                                    ),
                                  ],
                                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                                  popupDisplayOptions: PopupDisplayOptions(
                                    builder: (context, marker) {
                                      final match = enriched.firstWhere(
                                        (p) =>
                                            p["lat"] == marker.point.latitude &&
                                            p["lon"] == marker.point.longitude,
                                        orElse: () => {},
                                      );
                                      if (match.isEmpty) return const SizedBox();
                                      return Card(
                                        margin: const EdgeInsets.all(4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            match["name"] ?? "",
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (enriched.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(tr.noPharmaciesFound),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: enriched.length,
                              itemBuilder: (context, index) {
                                final p = enriched[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.local_pharmacy, color: Colors.green),
                                    title: Text(p["name"] ?? ""),
                                    subtitle: Text(tr.pharmacyDistance(p["distance"].toStringAsFixed(2))),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.map, color: Colors.green),
                                          tooltip: tr.openInMaps,
                                          onPressed: () => _openMapApp(context, p["lat"], p["lon"]),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.directions, color: Colors.blue),
                                          tooltip: tr.startNavigation,
                                          onPressed: () => _startNavigation(context, p["lat"], p["lon"]),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
    );
  }
}
