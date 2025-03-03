import ExpoModulesCore

public class ExpoMapExtensionModule: Module {

  public func definition() -> ModuleDefinition {
      Name("ExpoMapExtension")

      View(ExpoMapExtensionView.self) {

        Events("onSubmit", "onSelect")

        Prop("searchText") { (view: ExpoMapExtensionView, prop: String) in
            view.viewModel.searchText = prop
        }
      }
    }
  }
