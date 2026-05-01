import SwiftUI
import MapKit

struct SearchableMap: View {
    @Binding var searchText: String
    
    @State private var locationService = LocationService(completer: .init())
    @State private var searchResults = [SearchResult]()
    @State private var lastSearchText = ""
    @State private var isSearching = false

    
    var onSubmit: (([[String : Any]]) -> Void)?
    var onSelect: (([[String : Any]]) -> Void)?
    
    var body: some View {
        // Invisible container that handles all the logic
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                // Initialize location service
                locationService.update(queryFragment: searchText)
            }
            .onChange(of: searchText) { oldValue, newValue in
                handleSearchTextChange(newValue)
            }

    }
    
    private func handleSearchTextChange(_ newValue: String) {
        // Store the current search text to match with results
        lastSearchText = newValue
        isSearching = true
        
        // Update the location service with new search text
        locationService.update(queryFragment: newValue)
        
        // Poll for results instead of using onChange
        checkForResults()
    }
    
    private func checkForResults() {
        // Check if we have results and they're for the current search
        if !locationService.completions.isEmpty && isSearching {
            isSearching = false
            handleCompletionsUpdate(locationService.completions)
        } else if isSearching {
            // Keep checking every 100ms until we get results
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                checkForResults()
            }
        }
    }
    
    private func handleCompletionsUpdate(_ completions: [SearchCompletions]) {
        Task {
            await MainActor.run {
                // Submit the results
                if let onSubmit = onSubmit {
                    onSubmit(convertToDictionaryArray(searchCompletions: completions))
                }
                
                // Handle single completion selection
                if completions.count == 1, let firstCompletion = completions.first {
                    selectCompletion(firstCompletion)
                }
            }
        }
    }

    
    private func selectCompletion(_ completion: SearchCompletions) {
        Task {
            if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                await MainActor.run {
                    searchResults = [singleLocation]
                    onSelect?(convertToDictionaryArray(searchCompletions: [completion]))
                }
            }
        }
    }
    
    private func convertToDictionaryArray(searchCompletions: [SearchCompletions]) -> [[String: Any]] {
        return searchCompletions.map { completion in
            let id = completion.id.description
            let title = completion.title
            let subTitle = completion.subTitle
            let url = completion.url?.absoluteString ?? ""
            let phoneNumber = completion.phoneNumber ?? ""
            
            let placemarkName = (completion.placemark as AnyObject).name ?? ""
            let regionIdentifier = (completion.placemark as AnyObject).region?.identifier ?? ""
            let placemarkCoordinate: [String: Any] = [
                "latitude": (completion.placemark as AnyObject).coordinate.latitude,
                "longitude": (completion.placemark as AnyObject).coordinate.longitude
            ]
            
            return [
                "id": id,
                "title": title,
                "subTitle": subTitle,
                "url": url,
                "phoneNumber": phoneNumber,
                "placemark": [
                    "name": placemarkName,
                    "coordinate": placemarkCoordinate,
                    "region": regionIdentifier
                ]
            ]
        }
    }
}
