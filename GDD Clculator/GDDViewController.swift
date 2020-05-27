//
//  Created by Karthik Talakanti on 1/19/20.
//  Copyright © 2020 Karthik Talakanti. All rights reserved.
//

import UIKit
import SwiftCharts
	
class GDDViewController: UIViewController, weatherDataDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var stationsData = [stations]()
    @IBOutlet weak var GddCount: UILabel!
    @IBOutlet weak var plantingDate: UIDatePicker!
    @IBOutlet weak var sensingDate: UIDatePicker!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var usingRange: UILabel!
    let noInternetAlertController = UIAlertController(title: "Notification", message:
          "Check internet connection.", preferredStyle: UIAlertController.Style.alert)


    var reachability: Reachability?
    //checking for internet connection
    func checkReachability() -> Bool {
          var reachable = true
          do {
              try self.reachability = Reachability.init()
              if ((self.reachability!.connection) != .unavailable){
                 reachable = true
              }
              else{
                  reachable = false
              }
          }
          catch  {
              print("Error in Reachability")
          }
          return reachable
      }
    
    func itemsDownloaded(response: [stations]) {
    stationsData.removeAll()
    stationsData = response
    if(stationsData.count > 0){   // if results are present
        displayResults(responseData: stationsData)
        stationsTableView.reloadData()
    }
    else{
            self.present(dataUnavailableAlertController, animated: true, completion: nil)
        }
    }
    
    func displayResults (responseData : [stations]){
        selectedStation.isEnabled = true
        selectedStation.setTitle("Select a station", for: .normal)
        animateResults(toggle: true)
        stationsTableView.reloadData()
    }

    @IBOutlet weak var selectedStation: UIButton!
    
    @IBOutlet weak var stationsTableView: UITableView!
    
    
    @IBAction func onClickSelectedStation(_ sender: Any) {
    if self.stationsTableView.isHidden {animateResults(toggle: true)}
        else{animateResults(toggle: false)}
        GddCount.isHidden = !(GddCount.isHidden)
        usingRange.isHidden = !(usingRange.isHidden)

    }
    
    func animateResults(toggle: Bool){
        if toggle {UIView.animate(withDuration: 0.0) {self.stationsTableView.isHidden = false            }}
        else{UIView.animate(withDuration: 0.0) {self.stationsTableView.isHidden = true            }}
    }
    
    var jsonResponse: String?
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(tableView == stationsTableView){
            return self.stationsData.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =   tableView.dequeueReusableCell(withIdentifier: "Cell",for:indexPath)
        if(tableView == stationsTableView){
           
            cell.textLabel?.text = String( stationsData[indexPath.row].station!.dropFirst(6))
         }
        return cell
        }
              
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStation.setTitle("Station: "+self.stationsData[indexPath.row].station!.dropFirst(6), for: .normal)
        animateResults(toggle: false)
        stationsTableView.reloadData()
        self.GddCount.text = "GDD count: " + String(stationsData[indexPath.row].stationGDDCount ?? 0)
        self.GddCount.isHidden = false
        let df = DateFormatter()
        df.dateFormat = "MMM dd"
        self.usingRange.text = "Using data from " + df.string(from: (stationsData[indexPath.row].stationData?.first?.date)!) + " to " + df.string(from: (stationsData[indexPath.row].stationData?.last?.date)!)
        self.usingRange.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        zipcode.delegate = self
        noInternetAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        if (!checkReachability()){
                    self.present(noInternetAlertController, animated: true, completion: nil)
                }
        incorrectDatesAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        plantingDateAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        sensingDateAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        zipcodeAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        dataUnavailableAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
    }
    
    
    
    let zipcodeAlertController = UIAlertController(title: "Notification", message:"Zipcode should have 5 digits.", preferredStyle: UIAlertController.Style.alert)
    let plantingDateAlertController = UIAlertController(title: "Notification", message:"Planting date should be before current date.", preferredStyle: UIAlertController.Style.alert)
    let sensingDateAlertController = UIAlertController(title: "Notification", message:"Sensing date should be before current date.", preferredStyle: UIAlertController.Style.alert)
    let incorrectDatesAlertController = UIAlertController(title: "Notification", message:"Sensing date should be on or after planting date.", preferredStyle: UIAlertController.Style.alert)
    let dataUnavailableAlertController = UIAlertController(title: "Notification", message:"No NOAA weather data available for this selection, use different dates or another location. For a list of stations see https://www.ncdc.noaa.gov/data-access/land-based-station-data/find-station.", preferredStyle: UIAlertController.Style.alert)
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = zipcode.text ?? ""
        guard let stringRange = Range(range, in: currentText ) else{
            return false    
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if(updatedText.count>5){
            self.view.endEditing(true)
        }
        return updatedText.count < 6
    }
    
    
    @IBAction func dismissKeyboardOnTap(_ sender: UIView) {
        self.view.endEditing(true)
    }
    
    
    func validatePlantingDate() -> Bool{
        
    if(Calendar.current.compare(plantingDate.date, to: Date(), toGranularity: .day).rawValue <= 0){
            return true
        }
        else{
            self.present(plantingDateAlertController, animated: true, completion: nil)
               return false
        }
    }
  
     
    func validateSensingDate() -> Bool{
       
        if(Calendar.current.compare(sensingDate.date, to: Date(), toGranularity: .day).rawValue <= 0){
            if(Calendar.current.compare(plantingDate.date, to: sensingDate.date, toGranularity: .day).rawValue <= 0){
            return true
          }
            else{
                    self.present(incorrectDatesAlertController, animated: true, completion: nil)
                return false
            }
          }
          else{
            self.present(sensingDateAlertController, animated: true, completion: nil)
              return false
          }
      }
    
    
    
    func validateZipCode() -> Bool{
        if(self.zipcode.text?.count ?? 0 < 5){
            self.present(zipcodeAlertController, animated: true, completion: nil)
            return false
        }
        return true
    }
   
    
    
    func validateAllFields() ->Bool{
        var allFieldsValid = true
        allFieldsValid = allFieldsValid && validatePlantingDate() && validateSensingDate() && validateZipCode()
        return allFieldsValid
    }
    
    @IBAction func calculate(_ sender: Any) {
        
        self.view.endEditing(true)
        self.usingRange.isHidden = true
        self.GddCount.isHidden = true
        self.stationsTableView.isHidden = true
        if (!checkReachability()){
            self.present(noInternetAlertController, animated: true, completion: nil)
        }
        else{
        if(validateAllFields()){
            let weatherData1 = weatherData()
            weatherData1.getItems(startDate: plantingDate.date, endDate: sensingDate.date, zipCode: zipcode.text ?? "XXXXX")
                 weatherData1.delegate = self
        }
        }
        return
    }
}
