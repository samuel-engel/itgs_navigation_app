//
//  Location.swift
//  itgs_ia
//
//  Created by Samuel Engel on 12.12.18.
//

import Foundation
import MapKit
//class for defining location objects used in annotations
class Location: NSObject, MKAnnotation {
    let block: String
    let title: String?
    let location_description: String
    let coordinate: CLLocationCoordinate2D
    let floor: String
    
    init(block: String, title: String, location_description: String, coordinate: CLLocationCoordinate2D, floor: String) {
        self.block = block
        self.title = title
        self.location_description = location_description
        self.coordinate = coordinate
        self.floor = floor
        
        super.init()
    }
    // parser to convert json data into predefined values
    init?(json: [Any]) {
        self.block = json[0] as! String
        self.title = json[1] as? String ?? "No Title"
        self.location_description = json[2] as! String
        self.floor = json[5] as! String
        let latitude = json[3]
        let longitude = json[4]
        self.coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
    }
    
    //use description as a subtitle in annotations
    var subtitle: String? {
        return location_description
    }
}
