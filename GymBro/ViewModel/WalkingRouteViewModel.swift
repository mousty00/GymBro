import SwiftUI
import CoreLocation
import MapKit

final class WalkingRouteViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationUpdated: Bool = false
    @Published var route: MKRoute?
    @Published var locationError: String?
    private var locationManager: CLLocationManager?

    override init() {
        super.init()
        checkIsLocationEnabled()
    }

    func checkIsLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            DispatchQueue.main.async {
                self.locationError = "Location services are off. Please turn them on."
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.checkLocationAuthorization()
        }
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.async {
                self.locationError = "Your location is restricted."
            }
        case .denied:
            DispatchQueue.main.async {
                self.locationError = "You have denied location access for this app. Please enable it in Settings."
            }
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
                self.locationUpdated.toggle()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Failed to find user's location: \(error.localizedDescription)"
        }
    }
    
    func calculateWalkingRoute(time: Int) {
        guard let userLocation = userLocation else {
            DispatchQueue.main.async {
                self.locationError = "User location not available."
            }
            return
        }

        let walkingSpeed: Double = 1.4
        let maxDistance = (walkingSpeed * Double(time)) / 2

        let destinationLatitude = userLocation.latitude + (maxDistance / 111_320)
        let destinationLongitude = userLocation.longitude + (maxDistance / (111_320 * cos(userLocation.latitude * .pi / 180)))
        let destination = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)

        // Directions request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking

        // Calculate the route
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.locationError = "Error calculating route: \(error.localizedDescription)"
                }
                return
            }

            if let route = response?.routes.first {
                DispatchQueue.main.async {
                    self.route = route
                }
            }
        }
    }
    
    func resetRoute() {
        self.route = nil
    }


}

