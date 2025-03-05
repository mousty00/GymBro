import SwiftUI
import CoreLocation
import MapKit

struct WalkingRouteView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var walkingTime: Int = 10 // Valore predefinito
    @State private var route: MKRoute?
    @State private var showingRoute = false
    
    // Range di minuti per il Picker
    private let walkingTimes = Array(1...60)
    
    var body: some View {
        VStack {
            Text("Seleziona il tempo di camminata (minuti):")
                .font(.headline)
            
            // Picker per selezionare i minuti
            Picker("Minuti", selection: $walkingTime) {
                ForEach(walkingTimes, id: \.self) { time in
                    Text("\(time) min")
                }
            }
            .pickerStyle(WheelPickerStyle()) // Stile a ruota
            .frame(height: 150) // Altezza del Picker
            
            Button(action: {
                calculateRoute(for: walkingTime)
            }) {
                Text("Trova percorso")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if showingRoute, let route = route {
                MapView(route: route)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .padding()
    }
    
    private func calculateRoute(for minutes: Int) {
        guard let userLocation = locationManager.location else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        
        // Esempio di destinazione (puoi cambiarla con una logica più complessa)
        let destinationCoordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude + 0.01, longitude: userLocation.coordinate.longitude + 0.01)
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            self.route = route
            self.showingRoute = true
        }
    }
}

struct MapView: UIViewRepresentable {
    var route: MKRoute
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.addOverlay(route.polyline)
        uiView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
}

#Preview {
    WalkingRouteView()
}
