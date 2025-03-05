import SwiftUI
import CoreLocation
import MapKit

struct WalkingRouteView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var walkingTime: Int = 10
    @State private var route: MKRoute?
    @State private var showingRoute = false
    
    private let walkingTimes = Array(1...60)
    
    var body: some View {
        VStack {
            if locationManager.authorizationStatus == .denied {
                LocationPermissionView()
            } else {
                Text("Seleziona il tempo di camminata (minuti):")
                    .font(.headline)
                
                Picker("Minuti", selection: $walkingTime) {
                    ForEach(walkingTimes, id: \.self) { time in
                        Text("\(time) min")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                
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
                } else {
                    Text("Nessun percorso trovato o mappa non disponibile")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .padding()
    }
    
    private func calculateRoute(for minutes: Int) {
        guard let userLocation = locationManager.location else {
            print("Posizione dell'utente non disponibile")
            return
        }
        print("Posizione utente: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)") // Debug
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        
        // Modifica l'offset per la destinazione
        let destinationCoordinate = CLLocationCoordinate2D(
            latitude: userLocation.coordinate.latitude + 0.05,
            longitude: userLocation.coordinate.longitude + 0.05
        )
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Errore nel calcolo del percorso: \(error.localizedDescription)") // Debug
                return
            }
            guard let route = response?.routes.first else {
                print("Nessun percorso trovato. Response: \(String(describing: response))") // Debug
                return
            }
            self.route = route
            self.showingRoute = true
            print("Percorso calcolato con successo") // Debug
        }
    }
}

struct LocationPermissionView: View {
    var body: some View {
        VStack {
            Text("Per utilizzare questa funzionalità, abilita la localizzazione nelle impostazioni.")
                .padding()
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Apri Impostazioni")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    var route: MKRoute
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.addOverlay(route.polyline)
        uiView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        print("Overlay aggiunto alla mappa") // Debug
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

#Preview {
    WalkingRouteView()
}
