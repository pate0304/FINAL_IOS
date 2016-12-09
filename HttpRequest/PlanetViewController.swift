//
//  PlanetViewController.swift
//  HttpRequest
//
//  Created by Seb L on 2016-11-16.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

import UIKit
import MapKit
class PlanetViewController: UIViewController {

    @IBOutlet weak var mapsView: MKMapView!
    // Create the UI outlets
    @IBOutlet weak var overviewLabel: UILabel!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var moonLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var planetImageView: UIImageView!
    
    // Creat an int to identify the planet id that should be loaded
    var planetId: Int?
    
    override func viewDidLoad() {
        // When the view loads call the function to request the data, passing in the current planetId
        loadPlanetInfo(planetId!)
    }
    
    
    func loadPlanetInfo(_ id: Int) {
        
        // Create the URLSession object that will be used to make the requests
        let mySession: URLSession = URLSession.shared
        
        // Define the url that you want to send a request to for the planet JSON data
        let planetRequestUrl: URL = URL(string: "https://doors-open-ottawa-hurdleg.mybluemix.net/buildings/" + id.description)!
        // Create the request object and pass in your url
        var planetRequest: URLRequest = URLRequest(url: planetRequestUrl)
        // Make the specific task from the session by passing in your JSON data request, and the function that will be use to handle the data request
        //let planetTask = mySession.dataTask(with: planetRequest, completionHandler: planetRequestTask)
        let authString = "pate0304:password"
        let utf8String = authString.data(using: String.Encoding.utf8)
        //        if let base64String = utf8String?.base64EncodedStringWithOptions(Data.Base64EncodingOptions(rawValue: 0))
        if  let dataStr = utf8String?.base64EncodedString(options: [])
            
        {
            planetRequest.addValue("Basic " +  dataStr, forHTTPHeaderField: "Authorization")
        }

        
        let planetTask = mySession.dataTask(with: planetRequest, completionHandler: planetRequestTask )

        // Tell the JSON data task to run
        planetTask.resume()
        
        // Define the url that you want to send a request to for the image data
        let imageRequestUrl: URL = URL(string: "https://doors-open-ottawa-hurdleg.mybluemix.net/buildings/" + id.description + "/image")!
        // Create the request object and pass in your url
        var imageRequest: URLRequest = URLRequest(url: imageRequestUrl)
        // Make the specific task from the session by passing in your image request, and the function that will be use to handle the image request
        
//        let authString = "pate0304:password"
//        let utf8String = authString.data(using: String.Encoding.utf8)
        //        if let base64String = utf8String?.base64EncodedStringWithOptions(Data.Base64EncodingOptions(rawValue: 0))
        if  let dataStr = utf8String?.base64EncodedString(options: [])
            
        {
            imageRequest.addValue("Basic " +  dataStr, forHTTPHeaderField: "Authorization")
        }

        
        
        let imageTask = mySession.dataTask(with: imageRequest, completionHandler: imageRequestTask )

        
        //let imageTask = mySession.dataTask(with: imageRequest, completionHandler: imageRequestTask)
        // Tell the image task to run
        imageTask.resume()
        
    }
    
    
    // Define a function that will handle the JSON data request which will need to recieve the data send back, the response status, and an error object to handle any errors returned
    func planetRequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // If the error object has been set then an error occured
        if serverError != nil {
            // Send en empty string as the data, and the error to the callback function
            self.planetCallback("", error: serverError?.localizedDescription)
        }else{
            // If no error was generated then the server responce has been recieved
            // Stringify the response data
            let result = NSString(data: serverData!, encoding: String.Encoding.utf8.rawValue)!
            // Send the response string data, and nil for the error tot he callback
            self.planetCallback(result as String, error: nil)
        }
    }
    
    
    // Define the JSON data callback function to be triggered when the JSON data response is received
    func planetCallback(_ responseString: String, error: String?) {
        
        // If the server request generated an error then handle it
        if error != nil {
            print("ERROR is " + error!)
        }else{
            // Else take the data recieved from the server and process it
            print("DATA is " + responseString)
            
            // Define an optional dictionary that takes a string as the keys and any object as the values
            var jsonDictionary: [String:AnyObject]?
            
            // Take the response string and turn it back into raw data
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    // Try to convert response data into a dictionary to be saved into the optional dictionary
                    jsonDictionary = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:AnyObject]
                    
                } catch let convertError as NSError {
                    // If it fails catch the error info
                    print(convertError.description)
                }
            }
            
            // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
            DispatchQueue.main.async {
                
                // Cast the dictionary values from any objects to the appropriate type and set the UI outlets with the data
                self.title = jsonDictionary!["name"] as? String
                self.overviewLabel.text = jsonDictionary!["address"] as? String
                self.descriptionTextView.text = jsonDictionary!["description"] as? String
                let geocodedAddresses = CLGeocoder()
                geocodedAddresses.geocodeAddressString(jsonDictionary!["address"] as! String + " Ottawa", completionHandler: self.placeMarkerHandler )

                
                
                // Make variabes to hold Float and Int values to be used in setting the UI labels
//
                
            }
        }
        
        
    }
    
    func placeMarkerHandler (_ placeMarkers: [CLPlacemark]?, error: Error?) {
        if let firstMarker = placeMarkers?[0] {
            let marker = MKPlacemark(placemark: firstMarker)
            self.mapsView?.addAnnotation(marker)
            let myRegion = MKCoordinateRegionMakeWithDistance(marker.coordinate, 300, 300)
            self.mapsView?.setRegion(myRegion, animated: false)
        }
    }
    
    
    // Define a function that will handle the image request which will need to recieve the data send back, the response status, and an error object to handle any errors returned
    func imageRequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // If the error object has been set then an error occured
        if serverError != nil {
            // Send en empty string as the data, and the error to the callback function
            print("ERROR is " + serverError!.localizedDescription)
        }else{
            // Else take the image data recieved from the server and process it
            // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
            DispatchQueue.main.async {
                // Set the ImageView's image by converting the data object into a UIImage
                self.planetImageView.image = UIImage(data: serverData!)
            }
        }
    }
    
    
    
}
