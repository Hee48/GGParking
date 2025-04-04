//
//  ViewController.swift
//  GGParking
//
//  Created by Hee  on 4/2/25.
//
//

import UIKit
import MapKit
import CoreLocation




class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchMoveButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    
    let apiKey = "6d0c002a5823469c88df2b45cde53488"
    var parkingPlaces: [[String:String]] = []
    var key:String?
    var userLocation: CLLocation?// 현재 위치 저장
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    func searchParking(sigun:String) {
        let endPoint = "https://openapi.gg.go.kr/ParkingPlace?KEY=\(apiKey)&Type=xml&SIGUN_NM=\(sigun)"
        guard let url = URL(string: endPoint) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }.resume()
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func geocoderRoadAddress() {
        guard let userLoc = userLocation else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLoc) { placemark, error in
            if let error = error {
                print("\(error)")
            }
            if let placemark = placemark?.first,
               let city = placemark.locality {
                self.searchParking(sigun: city)
                print(city)
            }
        }
    }
    func setupMapView() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.showsUserLocation = true
    }
    //현재 위치를 핀으로 띄우는것
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        self.userLocation = latestLocation
        let location = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let pin = MKPointAnnotation()
        let region = MKCoordinateRegion(center: location, span: span)
        pin.coordinate = location
        pin.title = "내위치"
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(pin)
        geocoderRoadAddress()
        
    }
    //현재 위치 주변의 핀을 띄우는것 > for문으로 작업
    func surroundParkingPins() {
        let parkingData = parsingData()
        for parkPin in parkingData {
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: parkPin.latitude, longitude: parkPin.longitude)
            pin.title = parkPin.name
            mapView.addAnnotation(pin)
        }
        
    }
    func parsingData() -> [(name: String, latitude: Double, longitude: Double)] {
        var parsingArray: [(name: String, latitude:Double, longitude: Double)] = []
        
        for place in parkingPlaces {
            if let name = place["SIGUN_NM"],
               let latString = place["REFINE_WGS84_LAT"],
               let lonString = place["REFINE_WGS84_LOGT"],
               let latitude = Double(latString),
               let longtiude = Double(lonString) {
                parsingArray.append((name, latitude, longtiude))
            }
        }
        return parsingArray
    }
}
extension ViewController: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("Start")
        parkingPlaces.removeAll()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "row" {
            self.parkingPlaces.append([:])
        } else {
            self.key = elementName
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let key = key, var lastParking = parkingPlaces.last else { return }
        
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            lastParking[key] = trimmedString
            parkingPlaces[parkingPlaces.count - 1] = lastParking  // 최신 데이터 업데이트
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            //print(parkingPlaces)
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        print("End")
        surroundParkingPins()
    }
}
