import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = WalkingRouteViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var walkingTime: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAlert: Bool = false
    @State private var showSheet: Bool = false
    @State private var destination: CLLocationCoordinate2D?
    
    
    var body: some View {
        ZStack {
            Map {
                if let userLocation = viewModel.userLocation {
                    Marker(NSLocalizedString("You are here", comment: ""), coordinate: userLocation)
                        .tint(.pink)
                }
                
                if let route = viewModel.route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 4)
                }
                
            }
            .ignoresSafeArea(.keyboard)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if viewModel.route != nil {
                        CircleButton(image: "square.fill") {
                            viewModel.resetRoute()
                        }
                    } else {
                        
                        CircleButton(image: "figure.walk") {
                            DispatchQueue.main.async {
                                showSheet.toggle()
                            }
                        }
                        .sheet(isPresented: $showSheet) {
                            WalkInput(walkingTime: $walkingTime, viewModel: viewModel)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            viewModel.checkIsLocationEnabled()
        }
        .onChange(of: viewModel.locationError) { newError, _ in
            if newError != nil {
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(NSLocalizedString("Location Error", comment:"")), message: Text(viewModel.locationError ?? NSLocalizedString("Unknown error", comment: "")), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    MapView()
}
