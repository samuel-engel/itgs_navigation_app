//
//  ViewController.swift
//  itgs_ia
//
//  Created by Samuel Engel on 12.12.18.
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
            //load json file with location informations
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
        }
        //plot locations
        load_locations()
        mapView.addAnnotations(locations)
    }
    
    @IBOutlet weak var mark_switch: UISwitch!
    
    /*@IBAction func mark_clicked(_ sender: UISwitch) {
        if mark_switch.isOn {
            mapView.removeAnnotations(locations)
            mark_switch.setOn(false, animated:true)
            print("switch is on")
        } else {
            mapView.addAnnotations(locations)
            print("switch is off")
            mark_switch.setOn(true, animated:true)
        }
    }*/
    
    // hide annotations on switch change
    @IBAction func checked(_ sender: UISwitch) {
        if mark_switch.isOn {
            mapView.removeAnnotations(locations)
            mark_switch.setOn(false, animated:true)
            print("switch is on")
        } else {
            mapView.addAnnotations(locations)
            print("switch is off")
            mark_switch.setOn(true, animated:true)
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
    //run when user clicks the info button on any annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Location
        let title = location.title
        let block = location.block
        let floor = location.floor
        let ac = UIAlertController(title: title, message: "Can be found in the \(block) block \(floor)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}


