
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = WalkingRouteViewModel()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    var body : some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
                .ignoresSafeArea()
                .onAppear {
                    viewModel.checkIsLocationEnabled()
                }
    }
}


