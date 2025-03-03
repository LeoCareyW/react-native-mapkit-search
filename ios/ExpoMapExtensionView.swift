// import ExpoModulesCore

// // This view will be used as a native component. Make sure to inherit from `ExpoView`
// // to apply the proper styling (e.g. border radius and shadows).
// class ExpoMapExtensionView: ExpoView {

// }

import ExpoModulesCore
import SwiftUI

class ExpoMapViewModel : ObservableObject {
    @Published var inputText = "Initial Value"
    @Published var searchText = ""
}


struct ExpoMapView: View {
    @StateObject var viewModel: ExpoMapViewModel
    var onSubmit: (([[String : Any]]) -> Void)?
    var onSelect: (([[String : Any]]) -> Void)?

    var body: some View {
        SearchableMap(
            searchText: $viewModel.searchText,
            onSubmit: onSubmit,
            onSelect: onSelect
        )
    }
}


class ExpoMapExtensionView: ExpoView {

    private let contentView: UIHostingController<ExpoMapView>
    let viewModel = ExpoMapViewModel()

    let onSubmit: EventDispatcher
    let onSelect: EventDispatcher


    required init(appContext: AppContext? = nil) {
        onSubmit = EventDispatcher()
        onSelect = EventDispatcher()

        var handleSubmit: (([[String : Any]]) -> Void)?
        var handleSelect: (([[String : Any]]) -> Void)?


        contentView = UIHostingController(rootView: ExpoMapView(
            viewModel: self.viewModel,
            onSubmit: { inputText in handleSubmit?(inputText)},
            onSelect: { selectedItem in handleSelect?(selectedItem) }
        ))

        super.init(appContext: appContext)

        handleSubmit = { placesData in
            self.onSubmit(["placesData": placesData])
        }

        handleSelect = { selectedItem in
            self.onSelect(["selectedItem": selectedItem])
        }

        clipsToBounds = true
        addSubview(contentView.view)
    }

    override func layoutSubviews() {
        contentView.view.frame = bounds
    }
}

