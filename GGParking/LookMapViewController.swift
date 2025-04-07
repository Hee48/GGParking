//
//  LookMapViewController.swift
//  GGParking
//
//  Created by Hee  on 4/4/25.
//

import UIKit
import MapKit

class LookMapViewController: UIViewController {
    
    //ParkingInfo에서 데이터 넘겨받을 변수
    var latitude: Double?
    var longitude: Double?
    var parkingName: String?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var parkingNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoMapLocation()
        setupNameText()
        mapView.delegate = self
        
    }
    func setupNameText() {
        if let name = parkingName {
            parkingNameLabel.text = name.contains("주차장") ? name : "\(name) 주차장"
        } else {
            parkingNameLabel.text = "이름 없음"
        }
    }
    @IBAction func moveMainVC(_ sender: Any) {
        dismiss(animated: true)
    }
}
extension LookMapViewController: MKMapViewDelegate {
    //넘겨받은 위도경도로 그위치 띄우는거
    func infoMapLocation() {
        guard let lat = latitude, let lon = longitude else { return }
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        let pin = CustomAnnotation(coordinate: location, title: parkingName, icon: "placeholder")
        pin.coordinate = location
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(pin)
    }
    //커스텀어노테이션부분
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: annotation.icon)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        annotationView?.annotation = annotation
        return annotationView
    }
}

