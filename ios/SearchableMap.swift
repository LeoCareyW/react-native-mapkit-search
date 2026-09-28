import SwiftUI
import MapKit

struct SearchableMap: View {
    @Binding var searchText: String

    @StateObject private var locationService = LocationService()

    var onSubmit: (([[String : Any]]) -> Void)?
    var onSelect: (([[String : Any]]) -> Void)?

    var body: some View {
        // Invisible container that handles all the logic
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                if !searchText.isEmpty {
                    runSearch(searchText)
                }
            }
            .onChange(of: searchText) { oldValue, newValue in
                runSearch(newValue)
            }
    }

    private func runSearch(_ query: String) {
        locationService.search(query) { results in
            onSubmit?(convertToDictionaryArray(searchCompletions: results))

            // Handle single result selection
            if results.count == 1 {
                onSelect?(convertToDictionaryArray(searchCompletions: results))
            }
        }
    }

    private func convertToDictionaryArray(searchCompletions: [SearchCompletions]) -> [[String: Any]] {
        return searchCompletions.map { completion in
            let placemark = completion.placemark
            let placemarkCoordinate: [String: Any] = [
                "latitude": placemark?.coordinate.latitude ?? 0,
                "longitude": placemark?.coordinate.longitude ?? 0
            ]
            
            var dictionary: [String: Any] = [
                "id": completion.stableId,
                "transientId": completion.id.description,
                "mapItemId": completion.mapItemId ?? "",
                "title": completion.title,
                "subTitle": completion.subTitle,
                "address": completion.address.asDictionary,
                "url": completion.url?.absoluteString ?? "",
                "phoneNumber": completion.phoneNumber ?? "",
                "placemark": [
                    "name": placemark?.name ?? "",
                    "coordinate": placemarkCoordinate,
                    "region": placemark?.region?.identifier ?? ""
                ]
            ]
            // Omitted rather than sent as null when unknown
            if let category = completion.category {
                dictionary["category"] = category
            }
            if let distanceMeters = completion.distanceMeters {
                dictionary["distanceMeters"] = distanceMeters
            }
            return dictionary
        }
    }
}
