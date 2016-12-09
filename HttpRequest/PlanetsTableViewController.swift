//
//  myTableViewController.swift
//  HttpRequest
//
//  Created by Seb L on 2016-11-13.
//  Copyright © 2016 Algonquin College. All rights reserved.
//

import UIKit

class PlanetsTableViewController: UITableViewController {

    
    // Create the UI outlets
    @IBOutlet var myTableView: UITableView!
    
    // Define an optionl object to store the JSON response data.  In this case the planets JSON data has a key called 'planets' with a value that is equal to an array of dictionaries
    var jsonObject: [String:[[String:AnyObject]]]?
    
    
    // Theh load button action is used to get the JSON data forr all the plpanets
    @IBAction func loadButtonAction(_ sender: AnyObject) {
        
        // Update navbar title to show loading status
        self.title = "Loading"
        
        let requestUrl: URL = URL(string: "https://doors-open-ottawa-hurdleg.mybluemix.net/buildings/")!
        // Create the request object and pass in your url
        var myRequest: URLRequest = URLRequest(url: requestUrl)
        
        let authString = "pate0304:password"
        let utf8String = authString.data(using: String.Encoding.utf8)
        //        if let base64String = utf8String?.base64EncodedStringWithOptions(Data.Base64EncodingOptions(rawValue: 0))
        if  let dataStr = utf8String?.base64EncodedString(options: [])
            
        {
            myRequest.addValue("Basic " +  dataStr, forHTTPHeaderField: "Authorization")
        }
        
        // Create the URLSession object that will make the request
        let mySession: URLSession = URLSession.shared
        // Make the specific task from the session by passing in your request, and the function that will be use to handle the request
        
        let myTask2 = mySession.dataTask(with: myRequest, completionHandler: requestTask )
        //let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask)
        // Tell the task to run
        myTask2.resume()
    
    }
    
    
    
    // Define a function that will handle the request which will need to recieve the data send back, the respinse status, and an error object to handle any errors returned
    func requestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // If the error object has been set then an error occured
        if serverError != nil {
            
            // Send en empty string as the data, and the error to the callback function
            self.myCallback("", error: serverError?.localizedDescription)
            
        }else{
            
            // If no error was generated then the server responce has been recieved
            // Stringify the response data
            let result = NSString(data: serverData!, encoding: String.Encoding.utf8.rawValue)!
            // Send the response string data, and nil for the error tot he callback
            self.myCallback(result as String, error: nil)
            
        }
    }
    
    
    // Define the callback function to be triggered when the response is received
    func myCallback(_ responseString: String, error: String?) {
        
        // If the server request generated an error then handle it
        if error != nil {
            print("ERROR is " + error!)
        }else{
            // Else take the data recieved from the server and process it
            print("DATA is " + responseString)
            
            // Take the response string and turn it back into raw data
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    // Try to convert response data into a JSON dictionary to be saved into the optional dictionary
                    jsonObject = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:[[String:AnyObject]]]
                    
                } catch let convertError as NSError {
                    // If converting the string back into data fails catch the error info
                    print(convertError.description)
                }
            }
            
            // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
            DispatchQueue.main.async {
                // Update the tableView with the data in the JSON dictionary
                self.tableView!.reloadData()
                // Update navbar title to show loading is done
                self.title = "Buildings"
            }
        }
    }
    
    
    // Create a table cell for each item in the array if it is not nil, otherwise return 0
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var cellCount = 0
        
        // Use optional binding to return the count of the jsonObject array
        if let jsonObj = jsonObject{
            if let jsonArray = jsonObj["buildings"] as [[String:AnyObject]]? {
                cellCount = jsonArray.count
            }
        }
        print(cellCount)
        return cellCount
    }
    
    
    // For each dictionary in the JSON array add the info to each table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        // Use optional binding to access the JSON dictionary if it exists
        if let jsonObj = jsonObject{
            
            // Use optional binding to get the array of values from the JSON object
            if let jsonArray = jsonObj["buildings"] as [[String:AnyObject]]? {
                
                // For the current tableCell row get the corresponding planet's dictionary of info
                let dictionaryRow = jsonArray[indexPath.row] as [String:AnyObject]
                
                // Get the name and overview for the current planet
                let name = dictionaryRow["name"] as? String
                let overview = dictionaryRow["address"] as? String
                
                // Add the name and overview to the cell's textLabel
                cell.textLabel?.text = name! + " - " + overview!
            }
        }
        
        return cell
    }
    
    
    // Pass the current planet id to the next view when a cell is clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlanet" {
            // Get a reference to the next viewController class
            let nextVC = segue.destination as? PlanetViewController
            // Get a reference to the cell that was clicked
            let thisCell = sender as? UITableViewCell
            // Set the planetId value of the next viewController
            nextVC?.planetId = tableView.indexPath(for: thisCell!)!.row
            
        }
    }
    
    
}
