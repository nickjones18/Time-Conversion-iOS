// Nicholas Jones

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    
    var latitude: Double = 0
    var longitude: Double = 0
    var city = ""
    var regionName = ""
    var convertAddress : String = ""
    var gmtOffset = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.convertButton.addTarget(self, action: #selector(convertNow), forControlEvents: .TouchUpInside)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
        self.latitude = location!.coordinate.latitude
        self.longitude = location!.coordinate.longitude
        
        print(latitude)
        print(longitude)
        
        getMyJSON()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    // Views that need to be accessible to all methods
    let jsonResult = UILabel()
    
    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(theData : NSData) {
        
        // Print the provided data
        print("")
        print("====== the data provided to parseMyJSON is as follows ======")
        print(theData)
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            // Do the initial de-serialization
            // Source JSON is here:
            // http://vip.timezonedb.com/v2/get-time-zone?key=4J80KMFBHEP8&by=position&lat=48.8583654&lng=2.2960654&format=json
            //
            let json = try NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions.AllowFragments) as! AnyObject
            
            // Print retrieved JSON
            print("")
            print("====== the retrieved JSON is as follows ======")
            print(json)
            
            // Now we can parse this...
            print("")
            print("Now, add your parsing code here...")
            
            if let value = json["cityName"] as? [AnyObject] {
                /*for (a,b) in value {
                    print(a + " : " + b)
                }*/
                print(value)
            }
            
            if let value = json as? [String : AnyObject!] {
                
                let regionNameOpt = (value["regionName"])
                print (String(regionNameOpt))
                if let regionName = regionNameOpt{
                    print(regionName)
                    
                    if convertAddress == ""{
                    self.zoneLocation.text = "\(regionName)"
                    }
                }
                
                let gmtOffsetOpt = (value["gmtOffset"])
                print (String(gmtOffsetOpt))
                if let gmtOffset = gmtOffsetOpt{
                    print(gmtOffset)
                }
                
            }
            
            
            // Now we can update the UI
            // (must be done asynchronously)
            dispatch_async(dispatch_get_main_queue()) {
                self.jsonResult.text = "parsed JSON should go here"
            }
            
        } catch let error as NSError {
            print ("Failed to load: \(error.localizedDescription)")
        }
        
        
    }
    
    // Set up and begin an asynchronous request for JSON data
     func getMyJSON() {
        
        // Define a completion handler
        // The completion handler is what gets called when this **asynchronous** network request is completed.
        // This is where we'd process the JSON retrieved
        let myCompletionHandler : (NSData?, NSURLResponse?, NSError?) -> Void = {
            
            (data, response, error) in
            
            // This is the code run when the network request completes
            // When the request completes:
            //
            // data - contains the data from the request
            // response - contains the HTTP response code(s)
            // error - contains any error messages, if applicable
            
            // Cast the NSURLResponse object into an NSHTTPURLResponse objecct
            if let r = response as? NSHTTPURLResponse {
                
                // If the request was successful, parse the given data
                if r.statusCode == 200 {
                    
                    // Show debug information (if a request was completed successfully)
                    print("")
                    print("====== data from the request follows ======")
                    print(data)
                    print("")
                    print("====== response codes from the request follows ======")
                    print(response)
                    print("")
                    print("====== errors from the request follows ======")
                    print(error)
                    
                    if let d = data {
                        
                        // Parse the retrieved data
                        self.parseMyJSON(d)
                        
                    }
                    
                }
                
            }
            
        }
        
        // Define a URL to retrieve a JSON file from
        
        var address : String = "http://vip.timezonedb.com/v2/get-time-zone?key=4J80KMFBHEP8&by=position&lat=\(latitude)&lng=\(longitude)&format=json"
        
        if convertAddress != "" {
            
            print("No address")
            
            address = convertAddress
            
            let difference1 = gmtOffset
            print(difference1)
        }
        
        print("URL retrieved is: \(address)")
        
        // Try to make a URL request object
        if let url = NSURL(string: address) {
            
            // We have an valid URL to work with
            print(url)
            
            // Now we create a URL request object
            let urlRequest = NSURLRequest(URL: url)
            
            // Now we need to create an NSURLSession object to send the request to the server
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            // Now we create the data task and specify the completion handler
            let task = session.dataTaskWithRequest(urlRequest, completionHandler: myCompletionHandler)
            
            // Finally, we tell the task to start (despite the fact that the method is named "resume")
            task.resume()
            
        } else {
            
            // The NSURL object could not be created
            print("Error: Cannot create the NSURL object.")
            
        }
        
    }
    
    @IBOutlet weak var zoneLocation: UILabel!
    
    @IBOutlet weak var cityName: UITextField!
    
    @IBOutlet weak var convertButton: UIButton!
    
    func convertNow(){
        
        print("Converting...")
        
        if let city = cityName.text {
            print(city)
            
            convertAddress = "http://vip.timezonedb.com/v2/get-time-zone?key=4J80KMFBHEP8&by=city&country=CA&city=\(city)&format=json"
            
            getMyJSON()
            
            let difference2 = gmtOffset as! Int
            print(difference2)
            
        }
        
    }
    
}


// To complete my application, I need to take the time of the current location (already parced from json) and the time from the entered location (also already parced) and find the difference. The difference  This can then be displayed in many different forms, such as an alert or a simple label.




