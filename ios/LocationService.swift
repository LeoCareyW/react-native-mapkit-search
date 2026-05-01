import MapKit
import CoreLocation

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    var url: URL?
    var phoneNumber: String?
    var placemark: Any?
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let location: CLLocationCoordinate2D

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class LocationService: NSObject, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {
    private let completer: MKLocalSearchCompleter
    private let locationManager = CLLocationManager()
    
    var completions = [SearchCompletions]()
    @Published var userLocation: CLLocationCoordinate2D?
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
        
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
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

    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
        
        // Set the search region to user's location if available
        if let userLocation = userLocation {
            let region = MKCoordinateRegion(
                center: userLocation,
                latitudinalMeters: 10000, // 10km radius
                longitudinalMeters: 10000
            )
            completer.region = region
        } else {
            // Fallback to London
            let londonCoordinate = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
            let region = MKCoordinateRegion(
                center: londonCoordinate,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
            completer.region = region
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { completion in
            let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem

            return .init(
                title: completion.title,
                subTitle: completion.subtitle,
                url: mapItem?.url,
                phoneNumber: mapItem?.phoneNumber,
                placemark: mapItem?.placemark
            )
        }
    }

    func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResult] {
        let searchCoordinate: CLLocationCoordinate2D
        
        if let coordinate = coordinate {
            // Use provided coordinate
            searchCoordinate = coordinate
        } else if let userLocation = userLocation {
            // Use user's current location
            searchCoordinate = userLocation
        } else {
            // Fallback to London
            searchCoordinate = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        }
        
        let region = MKCoordinateRegion(
            center: searchCoordinate,
            latitudinalMeters: 10000, // 10km radius
            longitudinalMeters: 10000
        )

        let mapKitRequest = MKLocalSearch.Request()
        mapKitRequest.naturalLanguageQuery = query
        mapKitRequest.resultTypes = .pointOfInterest
        mapKitRequest.region = region

        let search = MKLocalSearch(request: mapKitRequest)
        let response = try await search.start()

        return response.mapItems.compactMap { mapItem in
            guard let location = mapItem.placemark.location?.coordinate else { return nil }
            return .init(location: location)
        }
    }
}
