import MapKit
import CoreLocation

struct Address {
    let streetNumber: String?
    let street: String?
    let neighbourhood: String?
    let city: String?
    let county: String?
    let state: String?
    let postcode: String?
    let country: String?
    let countryCode: String?

    init(placemark: MKPlacemark?) {
        streetNumber  = placemark?.subThoroughfare
        street        = placemark?.thoroughfare
        neighbourhood = placemark?.subLocality
        city          = placemark?.locality
        county        = placemark?.subAdministrativeArea
        state         = placemark?.administrativeArea
        postcode      = placemark?.postalCode
        country       = placemark?.country
        countryCode   = placemark?.isoCountryCode
    }

    var asDictionary: [String: String] {
        let parts: [String: String?] = [
            "streetNumber":  streetNumber,
            "street":        street,
            "neighbourhood": neighbourhood,
            "city":          city,
            "county":        county,
            "state":         state,
            "postcode":      postcode,
            "country":       country,
            "countryCode":   countryCode
        ]
        return parts.compactMapValues { $0 }
    }
}

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    var url: URL?
    var address: Address
    var phoneNumber: String?
    var placemark: MKPlacemark?
    var mapItemId: String?
    var stableId: String = ""
    var category: String?
    var distanceMeters: CLLocationDistance?
}

extension SearchCompletions {
    /// Lowercased name plus 4dp coordinates — same place, same id, every search.
    static func derivedId(title: String, coordinate: CLLocationCoordinate2D) -> String {
        let name = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let lat = String(format: "%.4f", coordinate.latitude)
        let lon = String(format: "%.4f", coordinate.longitude)
        return "\(name)@\(lat),\(lon)"
    }

    /// "MKPOICategoryRestaurant" -> "restaurant"
    static func categoryName(_ category: MKPointOfInterestCategory?) -> String? {
        guard let raw = category?.rawValue else { return nil }
        let name = raw.hasPrefix("MKPOICategory") ? String(raw.dropFirst("MKPOICategory".count)) : raw
        return name.prefix(1).lowercased() + name.dropFirst()
    }

    init(mapItem: MKMapItem, userLocation: CLLocation?) {
        let placemark = mapItem.placemark
        let street = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        let addressLine = [street, placemark.locality, placemark.postalCode]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        var mapItemId: String?
        if #available(iOS 18.0, *) {
            mapItemId = mapItem.identifier?.rawValue
        }

        let title = mapItem.name ?? placemark.name ?? ""

        self.init(
            title: title,
            subTitle: addressLine,
            url: mapItem.url,
            address: Address(placemark: placemark),
            phoneNumber: mapItem.phoneNumber,
            placemark: placemark,
            mapItemId: mapItemId,
            // Apple's id when it exists, else name + coordinates rounded to
            // ~11m, which is stable for the same place across searches.
            stableId: mapItemId ?? Self.derivedId(title: title, coordinate: placemark.coordinate),
            category: Self.categoryName(mapItem.pointOfInterestCategory),
            distanceMeters: placemark.location.flatMap { userLocation?.distance(from: $0) }
        )
    }
}

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var searchTask: Task<Void, Never>?

    @Published var userLocation: CLLocationCoordinate2D?

    private static let londonCoordinate = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
    private static let searchRadius: CLLocationDistance = 10_000 // 10km
    private static let debounce: Duration = .milliseconds(250)

    override init() {
        super.init()

        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate

        // Stop updating once we have a location to save battery
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        // Keep London as fallback if location fails
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    // MARK: - Search

    private var searchRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: userLocation ?? Self.londonCoordinate,
            latitudinalMeters: Self.searchRadius,
            longitudinalMeters: Self.searchRadius
        )
    }

    /// Debounced search. Any in-flight search is cancelled, so `onResults` only
    /// ever fires for the most recent query.
    func search(_ query: String, onResults: @escaping @MainActor ([SearchCompletions]) -> Void) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchTask = nil
            Task { @MainActor in onResults([]) }
            return
        }

        let region = searchRegion
        let origin = userLocation.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        searchTask = Task {
            do {
                try await Task.sleep(for: Self.debounce)

                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = trimmed
                request.resultTypes = .pointOfInterest
                request.region = region

                let search = MKLocalSearch(request: request)
                let response = try await withTaskCancellationHandler {
                    try await search.start()
                } onCancel: {
                    search.cancel()
                }

                let results = response.mapItems.map {
                    SearchCompletions(mapItem: $0, userLocation: origin)
                }
                await Self.deliver(results, to: onResults)
            } catch is CancellationError {
                // Superseded by a newer query
            } catch let error as MKError where error.code == .loadingThrottled {
                // Keep the previous results rather than blanking the list
                print("MapKit search throttled")
            } catch {
                // MapKit reports "no results" as an error, so clear stale results
                await Self.deliver([], to: onResults)
            }
        }
    }

    /// Checks cancellation on the main actor, where `search(_:onResults:)` is
    /// called, so a newer query can't slip in between the check and the callback.
    @MainActor
    private static func deliver(_ results: [SearchCompletions], to onResults: @MainActor ([SearchCompletions]) -> Void) {
        guard !Task.isCancelled else { return }
        onResults(results)
    }
}
