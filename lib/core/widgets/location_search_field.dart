import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/google_places_service.dart';

class LocationSearchField extends StatefulWidget {
  final Function(PlaceDetails details) onLocationSelected;
  final VoidCallback? onCleared;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialLocationName;
  final String? label;
  final String? hintText;
  final bool showCoordinatesBadge;
  final EdgeInsetsGeometry margin;

  const LocationSearchField({
    Key? key,
    required this.onLocationSelected,
    this.onCleared,
    this.initialLatitude,
    this.initialLongitude,
    this.initialLocationName,
    this.label,
    this.hintText,
    this.showCoordinatesBadge = true,
    this.margin = const EdgeInsets.only(bottom: 16),
  }) : super(key: key);

  @override
  State<LocationSearchField> createState() => LocationSearchFieldState();
}

class LocationSearchFieldState extends State<LocationSearchField> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isFetchingDetails = false;
  Timer? _debounceTimer;

  double? _pinnedLat;
  double? _pinnedLng;
  String? _pinnedLocationName;

  @override
  void initState() {
    super.initState();
    _pinnedLat = widget.initialLatitude;
    _pinnedLng = widget.initialLongitude;
    _pinnedLocationName = widget.initialLocationName;
  }

  @override
  void didUpdateWidget(covariant LocationSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLatitude != oldWidget.initialLatitude ||
        widget.initialLongitude != oldWidget.initialLongitude) {
      setState(() {
        _pinnedLat = widget.initialLatitude;
        _pinnedLng = widget.initialLongitude;
        _pinnedLocationName = widget.initialLocationName;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _isSearching = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await GooglePlacesService.getAutocompleteSuggestions(trimmed);
        if (mounted) {
          setState(() {
            _suggestions
              ..clear()
              ..addAll(results);
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isFetchingDetails = true;
      _suggestions.clear();
      _searchCtrl.text = suggestion.mainText;
    });

    try {
      final details = await GooglePlacesService.getPlaceDetails(suggestion.placeId);
      if (details != null && mounted) {
        setState(() {
          _pinnedLat = details.latitude;
          _pinnedLng = details.longitude;
          _pinnedLocationName = details.displayName.isNotEmpty
              ? details.displayName
              : suggestion.mainText;
          _isFetchingDetails = false;
        });

        HapticFeedback.lightImpact();
        widget.onLocationSelected(details);
      } else {
        if (mounted) {
          setState(() {
            _isFetchingDetails = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingDetails = false;
        });
      }
    }
  }

  void clearLocation() {
    setState(() {
      _pinnedLat = null;
      _pinnedLng = null;
      _pinnedLocationName = null;
      _searchCtrl.clear();
      _suggestions.clear();
    });
    widget.onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final hasPinnedLocation = _pinnedLat != null && _pinnedLng != null;

    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned Coordinates Badge
          if (widget.showCoordinatesBadge && hasPinnedLocation)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'location_pinned'.tr,
                          style: const TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Lat: ${_pinnedLat?.toStringAsFixed(5)}, Lng: ${_pinnedLng?.toStringAsFixed(5)}",
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_pinnedLocationName != null && _pinnedLocationName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _pinnedLocationName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: clearLocation,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF15803D)),
                    label: Text(
                      'change_location'.tr,
                      style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

          // Search Input Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: widget.label ?? 'search_location_map'.tr,
                hintText: widget.hintText ?? 'search_location_hint'.tr,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                labelStyle: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.search_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                suffixIcon: _isSearching || _isFetchingDetails
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: Padding(
                          padding: EdgeInsets.all(13.0),
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                      )
                    : _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: clearLocation,
                          )
                        : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor, width: 1.8),
                ),
              ),
            ),
          ),

          // Suggestions List
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              constraints: const BoxConstraints(maxHeight: 260),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return ListTile(
                      dense: true,
                      horizontalTitleGap: 8,
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        item.mainText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: item.secondaryText.isNotEmpty
                          ? Text(
                              item.secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            )
                          : null,
                      onTap: () => _selectSuggestion(item),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
