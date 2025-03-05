
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        print("LocationManager inizializzato") // Debug
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.requestLocationAuthorization()
    }
    
    private func requestLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("Richiesta autorizzazione alla localizzazione...")
            locationManager.requestWhenInUseAuthorization() // Richiedi l'autorizzazione
        case .restricted, .denied:
            print("Autorizzazione alla localizzazione negata o limitata.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Autorizzazione alla localizzazione già concessa.")
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        print("Posizione ottenuta: \(location.coordinate)") // Debug
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        print("Stato autorizzazione: \(manager.authorizationStatus.rawValue)") // Debug
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Autorizzazione alla localizzazione concessa.")
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Autorizzazione alla localizzazione negata o limitata.")
        case .notDetermined:
            print("Autorizzazione alla localizzazione non ancora determinata.")
        @unknown default:
            break
        }
    }
}
