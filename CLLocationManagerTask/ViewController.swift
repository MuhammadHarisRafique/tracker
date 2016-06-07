//
//  ViewController.swift
//  CLLocationManagerTask
//
//  Created by IOS Developer on 18/05/2016.
//  Copyright © 2016 Slash Global. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var btnLocationMeOutlet: UIButton!
    @IBOutlet weak var txtBoxPlace: UITextField!
    @IBOutlet weak var lblDestinationPlace: UILabel!
    @IBOutlet weak var lblDestinationLatLong: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAccurcy: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblVariable: UILabel!
    
    var root: MKRoute?
    var timer = NSTimer()
    let locationManager = CLLocationManager()
    var annotation = MKPointAnnotation()
    let geocoder = CLGeocoder()
    var myCurrentLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    
    var routColor = UIColor.blueColor()
    var colorIndex:Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.mapView.delegate  = self
        self.hiddenAllLabel()
        self.longTouchOnMapKit()
        self.updateLocationByTime()
        

        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func timeFormatter(dateTime: NSDate) -> String{
        
        let formatter = NSDateFormatter()
        
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "dd-MM-yyyy,HH:mm:ss a"
//        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
//        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        return formatter.stringFromDate(dateTime)
        
    }
    
    func dateFormatter(dateTime: NSDate) -> String{
        
        let formatter = NSDateFormatter()
        
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.stringFromDate(dateTime)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        var unixTime = NSDate().timeIntervalSince1970 + NSTimeZone(name: "Europe/London")!.daylightSavingTimeOffsetForDate(NSDate())
        
      //  print(unixTime)
        
     //   unixTime = 1.45337328E9
        
        let time  = NSTimeInterval(unixTime)
        let nsdate = NSDate(timeIntervalSince1970: time)
        let unixtime = timeFormatter(nsdate)
        
        print(unixtime.componentsSeparatedByString(",")[0])
        
        print(unixtime.componentsSeparatedByString(",")[1])
//        
//        let unixDate = dateFormatter(nsdate)
//        print("date : \(unixDate)")
        
    }
    
    func getLocation(){
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.myCurrentLocation = location!.coordinate
        self.lblPosition.text = "Lat: \(reduceDecimalValue(location!.coordinate.latitude)), Long: \(reduceDecimalValue(location!.coordinate.longitude))"
        self.lblPosition.hidden = false
        
        geocoder.reverseGeocodeLocation(location!) { (Placemark, error) in
            
            if Placemark?.count != nil{
                
                var placeDetails: CLPlacemark!
                placeDetails = Placemark![0]
                self.lblSpeed.text = "Place: \(placeDetails.name!)"
                self.lblSpeed.hidden = false
                self.lblVariable.text = "\(placeDetails.location!.timestamp)"
                let time = self.timeFormatter(placeDetails.location!.timestamp)
                print(time)
                self.lblAccurcy.text = "Accuracy: \(placeDetails.location!.horizontalAccuracy)"
                self.lblAccurcy.hidden = false
                self.lblVariable.hidden = false
                
            }
        }
        
        
        self.locationManager.stopUpdatingLocation()
        
        
    }
    
    @IBAction func btnLocationMeAction(sender: AnyObject) {
        
        let latLong: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.507797, longitude: -0.130471)
        
        self.myCurrentLocation = latLong
        annotation.coordinate = CLLocationCoordinate2D(latitude: latLong.latitude  , longitude: latLong.longitude)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latLong.latitude, longitude: latLong.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(annotation)
        
        
        
        
    }
    
    
    
    
    
    func reduceDecimalValue(latORlong: Double) -> String {
        
        let fomartter = NSNumberFormatter()
        fomartter.maximumFractionDigits = 6
        fomartter.roundingMode = NSNumberFormatterRoundingMode.RoundDown
        let u = fomartter.stringFromNumber(latORlong)
        return u!
    }
    
    func latlongToDetails(latlong: [Double]) -> () {
        
        let latlongHardCode = CLLocation(latitude: (latlong[0]), longitude: (latlong[1]))
        let latitude_With_SixPlaces =  reduceDecimalValue(latlong[0])
        let longitude_With_SixPlaces =  reduceDecimalValue(latlong[1])
        
        self.lblPosition.text = "Position: lat: \(latitude_With_SixPlaces),long:  \(longitude_With_SixPlaces)"
        annotation.coordinate = latlongHardCode.coordinate
        geocoder.reverseGeocodeLocation(latlongHardCode) { (Placemark, error) in
            var placeDetails: CLPlacemark!
            placeDetails = Placemark![0]
            self.lblSpeed.text = "PlaceName: \(placeDetails.subAdministrativeArea!) \(placeDetails.subLocality!)"
            print(placeDetails.addressDictionary)
            
            
            let region  = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (latlong[0]),longitude: (latlong[1])), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
            
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(self.annotation)
            self.locationManager.stopUpdatingLocation()
            
        }
    }
    
    func address(address: String){
        
        
        geocoder.geocodeAddressString(address) { (placeMark, error) in
            
            if placeMark?.count != nil{
                
                let place: CLPlacemark = placeMark![0]
                let lat = self.reduceDecimalValue(place.location!.coordinate.latitude)
                let long = self.reduceDecimalValue(place.location!.coordinate.longitude)
                self.annotation.coordinate = (place.location?.coordinate)!
                
                self.lblDestinationLatLong.text = "Position: latitude\(lat), longitude\(long)"
                self.lblDestinationLatLong.hidden = false
                
                let region  = MKCoordinateRegion(center: place.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
                self.mapView.setRegion(region, animated: true)
                self.lblVariable.hidden = false
                
            }
            
        }
        
        
        
    }
    
    @IBAction func btnLocationAction(sender: AnyObject) {
        if txtBoxPlace.text != ""{
            self.address(txtBoxPlace.text!)
            
        }
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            
            let touchLocation = gestureReconizer.locationInView(self.mapView)
            
            let locationCoordinate = self.mapView.convertPoint(touchLocation,toCoordinateFromView: self.mapView)
            
            annotation.coordinate = locationCoordinate
            
            
            self.destinationLocation = locationCoordinate
            self.lblDestinationLatLong.text = "Destination: \(reduceDecimalValue(locationCoordinate.latitude)), \(reduceDecimalValue(locationCoordinate.longitude))"
            
            self.lblDestinationLatLong.hidden = false
            
            self.mapView.addAnnotation(annotation)
            
            let latLong = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            
            geocoder.reverseGeocodeLocation(latLong, completionHandler: { (placemarkDestination, error) in
                
                var placeDetails: CLPlacemark!
                placeDetails = placemarkDestination![0]
                
                self.lblDestinationPlace.text = "Destination: \(placeDetails.name!)"
                self.lblDestinationPlace.hidden = false
                
            })
            self.makeRoute()
            
            
        }
        
        if gestureReconizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        
    }
    
    
    /// ****** Update location by time ******///
    
    func updateLocationByTime(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(self.getLocation), userInfo: nil, repeats: true)
        
    }
    
    
    func hiddenAllLabel(){
        
        self.lblAccurcy.hidden = true
        self.lblVariable.hidden = true
        self.lblSpeed.hidden = true
        self.lblPosition.hidden = true
        self.lblDestinationPlace.hidden = true
        self.lblDestinationLatLong.hidden = true
        
    }
    
    func longTouchOnMapKit(){
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
        
        
    }
    
    func makeRoute(){
        
        
        if self.myCurrentLocation != nil && self.destinationLocation != nil{
            
            
            let sourcePlacemark = MKPlacemark(coordinate: self.myCurrentLocation!, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: self.destinationLocation!, addressDictionary: nil)
            
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            let directionRequest = MKDirectionsRequest()
            
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .Automobile
            directionRequest.requestsAlternateRoutes = true
            
            let colors = [UIColor.blueColor(), UIColor.grayColor(), UIColor.brownColor()]
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculateDirectionsWithCompletionHandler {
                
                (response, error) -> Void in
                
                if let response = response {
                    
                    let sortedRoutes: [MKRoute] = response.routes.sort({$0.expectedTravelTime < $1.expectedTravelTime})
                    
                    for route in sortedRoutes {
                        
                        self.root = route
                        self.routColor =  colors[self.colorIndex]
                        self.colorIndex += 1
                        self.mapView.addOverlay(self.root!.polyline, level: MKOverlayLevel.AboveRoads)
                        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
                        let rect = self.root!.polyline.boundingMapRect
                        self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                        
                    }
                }
                    
                else {
                    
                    if let error = error {
                        
                        print("Error: \(error)")
                        
                    }
                }
                
            }
            
        }
        
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polyrender = MKPolylineRenderer(overlay: overlay)
        polyrender.strokeColor = self.routColor
        polyrender.lineWidth = 5
        
        return polyrender
        
    }
    

    
    
}




