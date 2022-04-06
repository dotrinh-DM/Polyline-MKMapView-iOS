//
//  ViewController.swift
//  MKMapView
//
//  Created by dotrinh on 2022/04/05.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var customMkMapV: MKMapView!
    
    var locationManager = CLLocationManager()
    var coordArray:[CLLocationCoordinate2D] = []
    var centerAnchor:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        //Map view settings
        customMkMapV.delegate = self
        customMkMapV.mapType = MKMapType.standard
        customMkMapV.isZoomEnabled = true
        customMkMapV.isScrollEnabled = true
        customMkMapV.center = view.center
        
        // adding co-ordinates for poly line (added static, we can make it dyanamic)
        let coords1 = CLLocationCoordinate2D(latitude: 35.555139, longitude: 139.722241)
        let coords2 = CLLocationCoordinate2D(latitude: 35.555009941986874, longitude: 139.72272022691322)
        let coords3 = CLLocationCoordinate2D(latitude: 35.55596118732464, longitude: 139.7230868058718)
        let coords4 = CLLocationCoordinate2D(latitude: 35.55651062646226, longitude: 139.7212121315655)
        let coords5 = CLLocationCoordinate2D(latitude: 35.55573046119005, longitude: 139.72054398577677)
        
        // updating current location method
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        let userLocation:CLLocation = locations[0] as CLLocation
        let currentPosition = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        coordArray.append(currentPosition)
        let testline = MKPolyline(coordinates: coordArray, count: coordArray.count)
        if(centerAnchor == 0){
            let region = MKCoordinateRegion(center: currentPosition, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            customMkMapV.setRegion(region, animated: true)
            centerAnchor+=1
        }
        customMkMapV.addOverlay(testline)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        return MKOverlayRenderer()
    }
}

//other thread etx
extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}


