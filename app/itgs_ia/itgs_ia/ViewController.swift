//
//  ViewController.swift
//  itgs_ia
//
//

import UIKit
import MapKit

class ViewController: UIViewController {
    var locations: [Location] = []
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // set initial location to ISHR and zoom radius to 200 meters
        let initial_location = CLLocation(latitude: 52.363852, longitude: 9.733949)
        let region_radius: CLLocationDistance = 200
        
        //mapView.mapType = MKMapType.hybrid
        
        //zoom on the start of the app
        func centerMapOnLocation(location: CLLocation) {
            let coordinate_region = MKCoordinateRegion(center: location.coordinate,
                                                      latitudinalMeters: region_radius, longitudinalMeters: region_radius)
            mapView.setRegion(coordinate_region, animated: true)
        }
        centerMapOnLocation(location: initial_location)
        
        mapView.delegate = self
        
        func load_locations() {
            print("start of load_locations")
            //load json file with location information
            guard let file_name = Bundle.main.path(forResource: "marks", ofType: "json")
                else { return }
            let optionalData = try? Data(contentsOf: URL(fileURLWithPath: file_name))
            
            guard
                let data = optionalData,
                //serialize into json object
                let json = try? JSONSerialization.jsonObject(with: data),
                // grab location of objects as a dictionary
                let dictionary = json as? [[Any]]

                else { return }
            // append each obejct into the Locations array after going through the parser
            let valid_locations = dictionary.compactMap { Location(json: $0) }
            locations.append(contentsOf: valid_locations)
            print("end of load_socations")
        }
        //plot locations
        print("loading")
        load_locations()
        print(locations)
        mapView.addAnnotations(locations)
    }
    
    @IBOutlet weak var mark_switch: UISwitch!
    // hide annotations on switch change
    @IBAction func checked(_ sender: UISwitch) {
        if mark_switch.isOn {
            mapView.removeAnnotations(locations)
            mark_switch.setOn(false, animated:true)
        } else {
            mapView.addAnnotations(locations)
            mark_switch.setOn(true, animated:true)
        }
    }
    
    @IBOutlet weak var map_type_switch: UISwitch!
    //swich map type on switch change
    @IBAction func type_switched(_ sender: UISwitch) {
        if map_type_switch.isOn {
            mapView.mapType = MKMapType.satellite
            map_type_switch.setOn(false, animated:true)
        } else {
            mapView.mapType = MKMapType.standard
            map_type_switch.setOn(true, animated:true)
        }
    }
    
    
}
extension ViewController: MKMapViewDelegate {
    //function that gets called for every annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // change only annotations created through the custom Location class
        guard let annotation = annotation as? Location else { return nil }
        // set better marker style rather than default
        let identifier = "mark"
        var view: MKMarkerAnnotationView
        // if it was already loaded and only hidden because it went out of view, display it again
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // create the annotation
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    //run when user clicks the info button on an annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        let location = view.annotation as! Location
        let title = location.title
        let description = location.location_description
        
        //define alert message and display it
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}


