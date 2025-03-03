import SwiftUI
import MapKit

struct SearchableMap: View {
    @Binding var searchText: String

    @State private var locationService = LocationService(completer: .init())
    @State private var searchResults = [SearchResult]()
    @State private var selectedLocation: SearchResult?
    @State private var isSheetPresented: Bool = false

    var onSubmit: (([[String : Any]]) -> Void)?
    var onSelect: (([[String : Any]]) -> Void)?

    var body: some View {
        ZStack {
            // Empty container instead of Map
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    isSheetPresented = true
                }
                .onDisappear {
                    isSheetPresented = false
                }
                .onChange(of: selectedLocation) {
                    isSheetPresented = selectedLocation == nil
                }
                .onChange(of: searchResults) {
                    if let firstResult = searchResults.first, searchResults.count == 1 {
                        selectedLocation = firstResult
                    }
                }
                .onChange(of: searchText) {
                    isSheetPresented = true
                }

           if !isSheetPresented {
                VStack {
                    Spacer()
                    Button(action: {
                        isSheetPresented = true
                        Task {
                            let results = (try? await locationService.search(with: searchText)) ?? []
                            await MainActor.run {
                                searchResults = results
                            }
                        }
                    }) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 3)
                    }
                    .padding(.bottom, 20)
                }
            }
        }


        .sheet(isPresented: $isSheetPresented) {
            SheetView(
                searchText: $searchText,
                searchResults: $searchResults,
                onSubmit: onSubmit,
                onSelect: onSelect,
                locationService: locationService
            )
        }
    }
}

// import SwiftUI
// import MapKit

// struct SearchableMap: View {
//     @Binding var searchText: String
//     @State private var position = MapCameraPosition.automatic
//     @State private var searchResults = [SearchResult]()
//     @State private var selectedLocation: SearchResult?
//     @State private var isSheetPresented: Bool = false
//     @State private var scene: MKLookAroundScene?

//     var onSubmit: (([[String : Any]]) -> Void)?

//     var body: some View {
//         Map(position: $position, selection: $selectedLocation) {
//             ForEach(searchResults) { result in
//                 Marker(coordinate: result.location) {
//                     Image(systemName: "mappin")
//                 }
//                 .tag(result)
//             }
//         }
//          .overlay(alignment: .bottom) {
//              if selectedLocation != nil {
//                  LookAroundPreview(scene: $scene, allowsNavigation: false, badgePosition: .bottomTrailing)
//                      .frame(height: 200)
//                      .clipShape(RoundedRectangle(cornerRadius: 12))
//                      .safeAreaPadding(.bottom, 80)
//              }
//          }
//         .ignoresSafeArea()
//           .onAppear {
//             isSheetPresented = true
//         }
//         .onDisappear {
//             isSheetPresented = false
//         }
//         .onChange(of: selectedLocation) {
//             if let selectedLocation {
//                 Task {
//                     scene = try? await fetchScene(for: selectedLocation.location)
//                 }
//             }
//             isSheetPresented = selectedLocation == nil
//         }
//         .onChange(of: searchResults) {
//             if let firstResult = searchResults.first, searchResults.count == 1 {
//                 selectedLocation = firstResult
//             }

//         }
//         .sheet(isPresented: $isSheetPresented) {
//             SheetView(searchText: $searchText, searchResults: $searchResults, onSubmit: onSubmit)
//         }

//     }

//     private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
//         let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
//         return try await lookAroundScene.scene
//     }
// }
