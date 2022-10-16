//
//  ContentView.swift
//  ARRealityComposer
//
//  Created by Zaid Neurothrone on 2022-10-16.
//

import RealityKit
import SwiftUI

final class ViewModel: ObservableObject {
  @Published var text = ""
  
  var onScaleCloudNotification: () -> Void = {}
}

struct ContentView : View {
  @StateObject var viewModel: ViewModel = .init()
  
  var body: some View {
    VStack {
      ARViewContainer(viewModel: viewModel)
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Text(viewModel.text)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
        
        Button("Scale Cloud") {
          viewModel.onScaleCloudNotification()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: 100)
      .background(.purple)
      .foregroundColor(.white)
    }
  }
}

struct ARViewContainer: UIViewRepresentable {
  let viewModel: ViewModel
  
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    
    // Load the scene from the "Experience" Reality File
    let mainSceneAnchor = try! Experience.loadMainScene()
    
    let allDisplayActions = mainSceneAnchor.actions.allActions.filter {
      $0.identifier.hasPrefix("Display")
    }
    
    for displayAction in allDisplayActions {
      displayAction.onAction = { entity in
        if let entity {
          viewModel.text = entity.name
        }
      }
    }
    
    // What to do when SwiftUI triggers this notification
    viewModel.onScaleCloudNotification = {
      mainSceneAnchor.notifications.cloudScaleNotification.post()
    }
    
    // Add anchor to the scene
    arView.scene.anchors.append(mainSceneAnchor)
    
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {}
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
