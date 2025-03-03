import SwiftUI
import MapKit

struct SheetView: View {
    @State private var search: String = ""
    @State private var isKeyboardVisible = false
    
    @FocusState private var textFieldFocused: Bool

    @Binding var searchText: String
    @Binding var searchResults: [SearchResult]

    var onSubmit: (([[String : Any]]) -> Void)?
    var onSelect: (([[String : Any]]) -> Void)?
    var locationService: LocationService



    var body: some View {
        VStack {
            Spacer()
            List {
                ForEach(locationService.completions) { completion in
                    // 3
                    Button(action: { didTapOnCompletion(completion) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(completion.subTitle)
                            // What can we show?
                            if let url = completion.url {
                                Link(url.absoluteString, destination: url)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .id(UUID())
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { _ in isKeyboardVisible = true }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in isKeyboardVisible = false }
               }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .onChange(of: searchText) { oldValue, newValue in
          print("searchText changed:", newValue)
            locationService.update(queryFragment: newValue)
            Task {
                await MainActor.run {
                    if let onSubmit = onSubmit {
                        onSubmit(convertToDictionaryArray(searchCompletions: locationService.completions))
                    }
                }
            }
    }
        .padding()
        .presentationDetents(isKeyboardVisible ? [.height(400)] : [.height(150), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
    }
    

    // 4
    private func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                searchResults = [singleLocation]
                onSelect?(convertToDictionaryArray(searchCompletions: [completion]))
            }
        }
    }


    func convertToDictionaryArray(searchCompletions: [SearchCompletions]) -> [[String: Any]] {
        return searchCompletions.map { completion in
            let id = completion.id.description
            let title = completion.title
            let subTitle = completion.subTitle
            let url = completion.url?.absoluteString ?? ""
            let phoneNumber = completion.phoneNumber ?? ""


            let placemarkName = (completion.placemark as AnyObject).name ?? ""
            let regionIdentifier = (completion.placemark as AnyObject).region?.identifier ?? ""
            let placemarkCoordinate: [String: Any] = [
                "latitude": (completion.placemark as AnyObject).coordinate.latitude ,
                "longitude": (completion.placemark as AnyObject).coordinate.longitude
            ]

            // Create the dictionary
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

// hide native search bar
// have search bar within react application
// keep sheet view
// need to pass up selected location to react application
// maybe add a 'selected' prop inside the selected item, would have
// to add and remove it for each time another was selected

// FUTURE RELEASES
// get opening times etc
// link to website



//struct TextFieldGrayBackgroundColor: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .padding(12)
//            .background(.gray.opacity(0.1))
//            .cornerRadius(8)
//            .foregroundColor(.primary)
//    }
//}

