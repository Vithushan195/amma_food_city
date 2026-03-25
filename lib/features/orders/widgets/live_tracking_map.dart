import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/driver_location.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Amma Food City store location
const _storeLatLng = LatLng(55.8456, -4.4239);

/// Live map showing the driver's position, the store, and optionally
/// the customer's delivery address.
class LiveTrackingMap extends StatefulWidget {
  final DriverLocation? driverLocation;
  final LatLng? deliveryLatLng;

  const LiveTrackingMap({
    super.key,
    this.driverLocation,
    this.deliveryLatLng,
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  final Completer<GoogleMapController> _controller = Completer();
  bool _ready = false;

  LatLng get _driverPos => LatLng(
        widget.driverLocation?.latitude ?? _storeLatLng.latitude,
        widget.driverLocation?.longitude ?? _storeLatLng.longitude,
      );

  LatLng get _dropoff => widget.deliveryLatLng ?? _storeLatLng;

  @override
  void didUpdateWidget(covariant LiveTrackingMap old) {
    super.didUpdateWidget(old);
    if (_ready &&
        widget.driverLocation != null &&
        (old.driverLocation?.latitude != widget.driverLocation!.latitude ||
            old.driverLocation?.longitude !=
                widget.driverLocation!.longitude)) {
      _fitBounds();
    }
  }

  Future<void> _fitBounds() async {
    final c = await _controller.future;
    final sw = LatLng(
      _driverPos.latitude < _dropoff.latitude
          ? _driverPos.latitude
          : _dropoff.latitude,
      _driverPos.longitude < _dropoff.longitude
          ? _driverPos.longitude
          : _dropoff.longitude,
    );
    final ne = LatLng(
      _driverPos.latitude > _dropoff.latitude
          ? _driverPos.latitude
          : _dropoff.latitude,
      _driverPos.longitude > _dropoff.longitude
          ? _driverPos.longitude
          : _dropoff.longitude,
    );
    c.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne), 60));
  }

  Set<Marker> _markers() {
    final m = <Marker>{};

    m.add(Marker(
      markerId: const MarkerId('store'),
      position: _storeLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Amma Food City'),
    ));

    if (widget.driverLocation != null) {
      m.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Your Driver'),
      ));
    }

    if (widget.deliveryLatLng != null) {
      m.add(Marker(
        markerId: const MarkerId('delivery'),
        position: widget.deliveryLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Delivery Address'),
      ));
    }

    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.driverLocation != null ? _driverPos : _storeLatLng,
              zoom: 14,
            ),
            markers: _markers(),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (c) {
              _controller.complete(c);
              _ready = true;
              if (widget.driverLocation != null) {
                Future.delayed(const Duration(milliseconds: 500), _fitBounds);
              }
            },
          ),
          if (widget.driverLocation != null)
            Positioned(
              top: 12,
              right: 12,
              child: _FreshnessBadge(
                isFresh: widget.driverLocation!.isFresh,
                seconds: widget.driverLocation!.secondsSinceUpdate,
              ),
            ),
        ],
      ),
    );
  }
}

class _FreshnessBadge extends StatelessWidget {
  final bool isFresh;
  final int seconds;
  const _FreshnessBadge({required this.isFresh, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFresh ? AppColors.primary : Colors.orange[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFresh ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
            size: 14,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isFresh ? 'Live' : '${seconds}s ago',
            style: AppTypography.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
