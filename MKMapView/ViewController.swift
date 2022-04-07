//
//  ViewController.swift
//  MKMapView
//
//  Created by dotrinh on 2022/04/05.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var customMkMapV: MKMapView!
    @IBOutlet weak var autoCenter: UISwitch!
    @IBOutlet weak var speedLbl: UILabel!
    
    var locationManager = CLLocationManager()
    var coordArray:[CLLocationCoordinate2D] = []
    
    var synthesizer: AVSpeechSynthesizer!
    var voice: AVSpeechSynthesisVoice!
    var currentSpeed: String!

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
        
        
        // updating current location method
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.synthesizer = AVSpeechSynthesizer()
        self.voice = AVSpeechSynthesisVoice.init(language: "en-US")
    
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            if(!self.currentSpeed.elementsEqual("0.0")) {
                let str = "The speed is " + self.currentSpeed + "km/h"
                self.speak(str)
                print("speaking \(str)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("didUpdateLocations %@", userLocation)
        var speed = Float(userLocation.speed * 3.6)
        speed = speed <= 0 ? 0: speed;
        
        currentSpeed = String(format: "%.1f", speed)
        speedLbl.text = currentSpeed + " km/h"
        print("didUpdateLocations \(String(describing: currentSpeed))")
        
        let currentPosition = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        coordArray.append(currentPosition)
        let testline = MKPolyline(coordinates: coordArray, count: coordArray.count)
        if(autoCenter.isOn){
            let region = MKCoordinateRegion(center: currentPosition, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            customMkMapV.setRegion(region, animated: true)
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
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance.init(string: text)
        utterance.voice = self.voice
//        utterance.rate = 0.5
        self.synthesizer.speak(utterance)
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


