import MapKit

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

class LocationService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter

    var completions = [SearchCompletions]()


    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }



    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
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
    let londonCoordinate = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
    let region = MKCoordinateRegion(center: londonCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

    let mapKitRequest = MKLocalSearch.Request()
    mapKitRequest.naturalLanguageQuery = query
    mapKitRequest.resultTypes = .pointOfInterest

    if let coordinate = coordinate {
        mapKitRequest.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
    } else {
        mapKitRequest.region = region // Use London as fallback region if no coordinate is provided
    }

    let search = MKLocalSearch(request: mapKitRequest)
    let response = try await search.start()

    return response.mapItems.compactMap { mapItem in
        guard let location = mapItem.placemark.location?.coordinate else { return nil }
        return .init(location: location)
    }
}
}
