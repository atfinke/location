//
//  ViewController.swift
//  location plotter
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import MapKit

struct Point {
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D
}

class ViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties -
    
    let mapView = MKMapView()
    
    // MARK: - View Life Cycle -
    
    override func loadView() {
        mapView.delegate = self
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.path(forResource: "Locations", ofType: "csv"), let csv = try? String(contentsOfFile: path) else {
            fatalError()
        }
        
        let rows = csv.components(separatedBy: "\n")
        let dataRows = rows.dropFirst().dropLast()
        var points = [Point]()
        for row in Array(dataRows) {
            let rowItems = row.replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "\r", with: "")
                .components(separatedBy: ",")
            guard let rawTimestamp = Double(rowItems[2]) else {
                fatalError()
            }
            guard let lat = CLLocationDegrees(rowItems[1]), let lon = CLLocationDegrees(rowItems[3]) else {
                fatalError()
            }
            let timestamp = Date(timeIntervalSince1970: rawTimestamp)
            let cord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let point = Point(timestamp: timestamp, coordinate: cord)
            points.append(point)
        }

        let coords = points.sorted(by: { lhs, rhs -> Bool in
            return lhs.timestamp < rhs.timestamp
        }).map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)
        mapView.region = MKCoordinateRegion(center: coords[0], span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
    }
    
    // MARK: - MKMapViewDelegate -
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            fatalError()
        }
        let polylineRenderer = MKPolylineRenderer(polyline: polyline)
        polylineRenderer.strokeColor = .blue
        polylineRenderer.lineWidth = 4.0
        polylineRenderer.lineCap = .round
        polylineRenderer.lineJoin = .round
        return polylineRenderer
    }

}

