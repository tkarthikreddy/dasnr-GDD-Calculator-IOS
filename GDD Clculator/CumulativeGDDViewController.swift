//  GDD Clculator
//
//  Created by Karthik Talakanti on 1/19/20.
//  Copyright © 2020 Karthik Talakanti. All rights reserved.
//

import UIKit

class CumulativeGDDViewController: UIViewController, weatherDataDelegate ,
UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var StationsWithGDDData = [stationsGDD]()
    var selectedStationGDDData = stationsGDD()
    var stationsData = [stations]()
    let crops = ["Alfalfa", "Corn", "Cotton", "Grass Hay", "Peanuts", "Sorghum", "Soybean", "Wheat"]
    let cropsWithData = ["Alfalfa" : [Float(41),Float(86)], "Corn": [Float(50),Float(86)], "Cotton": [Float(60),Float(100)], "Grass Hay": [Float(50),Float(86)], "Peanuts": [Float(55),Float(95)], "Sorghum": [Float(55),Float(95)], "Soybean": [Float(50),Float(95)], "Wheat": [Float(32),Float(86)]]
    

    @IBOutlet weak var usingRange: UILabel!
    
    
    let noInternetAlertController = UIAlertController(title: "Notification", message:
          "Check internet connection.", preferredStyle: UIAlertController.Style.alert)


     var reachability: Reachability?
//check for internet
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
        if(stationsData.count > 0){
            displayResults(responseData: stationsData)
        }
        else{
            self.present(dataUnavailableAlertController, animated: true, completion: nil)
        }
    }
        
    func displayResults (responseData : [stations]){
        let cropTemps = self.cropsWithData[selectCrop.currentTitle!]
        StationsWithGDDData.removeAll()
        for dat in responseData{
            var DailyGDDData = [dailyGDD]()
            var cumulativeGDD : Float = 0.0
            for day in dat.stationData!{
                var GDD : Float = 0.0
                if((day.tmax?.isLess(than: cropTemps![1]))!){
                    GDD = ((day.tmax! + day.tmin!)/2)-cropTemps![0]
                }
                else{
                    GDD = ((cropTemps![1] + day.tmin!)/2)-cropTemps![0]
                }
                DailyGDDData.append(dailyGDD(date: day.date,gdd: GDD))
                cumulativeGDD += GDD
            }
            let station = dat.station?.dropFirst(6)
            
            StationsWithGDDData.append(stationsGDD(station: String(station!) ,stationDailyGDDData: DailyGDDData , stationCumulativeGDD: cumulativeGDD))
        }
        if StationsWithGDDData.count > 0 {
                selectedStation.setTitle("Select a station", for: .normal)
                animateResults(toggle: true)
                stationsTableView.reloadData()
        }
    }
  
    @IBOutlet weak var sensingDate: UIDatePicker!
    @IBOutlet weak var plantingDate: UIDatePicker!
    @IBOutlet weak var zipcode: UITextField!
    
    @IBOutlet weak var CumulativeGdd: UILabel!
    @IBAction func dismissKeyboardOnTap(_ sender: UIView) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var stationsTableView: UITableView!
    @IBOutlet weak var selectCrop: UIButton!
    @IBOutlet weak var cropsTableView: UITableView!
    @IBOutlet weak var resultsTableView: UITableView!
    
    let zipcodeAlertController = UIAlertController(title: "Notification", message:"Zipcode should have 5 digits.", preferredStyle: UIAlertController.Style.alert)
    let plantingDateAlertController = UIAlertController(title: "Notification", message:"Planting date should be before current date.", preferredStyle: UIAlertController.Style.alert)
    let sensingDateAlertController = UIAlertController(title: "Notification", message:"Sensing date should be before current date.", preferredStyle: UIAlertController.Style.alert)
    let incorrectDatesAlertController = UIAlertController(title: "Notification", message:"Sensing date should be on or after planting date.", preferredStyle: UIAlertController.Style.alert)
    let selectedCropAlertController = UIAlertController(title: "Notification", message:"Select a crop from the list.", preferredStyle: UIAlertController.Style.alert)
    let dataUnavailableAlertController = UIAlertController(title: "Notification", message:"No NOAA weather data available for this selection, use different dates or another location. For a list of stations see https://www.ncdc.noaa.gov/data-access/land-based-station-data/find-station.", preferredStyle: UIAlertController.Style.alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        cropsTableView.isHidden = true
        stationsTableView.isHidden = true
        resultsTableView.isHidden = true
        zipcode.delegate = self
        noInternetAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        if (!checkReachability()){
                    self.present(noInternetAlertController, animated: true, completion: nil)
                }
        incorrectDatesAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        plantingDateAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        sensingDateAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        zipcodeAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        selectedCropAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        dataUnavailableAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
    }
    
    
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
        allFieldsValid = allFieldsValid && validatePlantingDate() && validateSensingDate() && validateZipCode() && validateCrop()
         return allFieldsValid
     }
 
    func validateCrop() -> Bool{
        if( !self.crops.contains( self.selectCrop.currentTitle ?? "Select Crop") ){
            self.present(selectedCropAlertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    @IBOutlet weak var selectedStation: UIButton!
    @IBAction func calculate(_ sender: Any) {
        
        cropsTableView.isHidden = true
        resultsTableView.isHidden = true
        usingRange.isHidden = true
        CumulativeGdd.isHidden = true
        self.view.endEditing(true)
        if (!checkReachability()){
            self.present(noInternetAlertController, animated: true, completion: nil)
        }
        else{
        if(validateAllFields()){
            let weatherData2 = weatherData()
            weatherData2.getItems(startDate: plantingDate.date, endDate: sensingDate.date, zipCode: zipcode.text ?? "XXXXX")
            weatherData2.delegate = self
         }
        }
         return
     }
    @IBAction func onClickSelectCrop(_ sender: Any) {
        if self.cropsTableView.isHidden {animate(toggle: true)}
        else{animate(toggle: false)}
    }
    
    @IBAction func onClickSelectedStation(_ sender: Any) {
        resultsTableView.isHidden = !(resultsTableView.isHidden)
        CumulativeGdd.isHidden = !(CumulativeGdd.isHidden)
        usingRange.isHidden = !(usingRange.isHidden)
         if self.stationsTableView.isHidden {animateResults(toggle: true)}
        else{animateResults(toggle: false)}
    }
   func animateResults(toggle: Bool){
        if toggle {UIView.animate(withDuration: 0.0) {self.stationsTableView.isHidden = false}}
        else{UIView.animate(withDuration: 0.0) {self.stationsTableView.isHidden = true            }}
    }

    func animate(toggle: Bool){
        if toggle {UIView.animate(withDuration: 0.0) {self.cropsTableView.isHidden = false}}
        else{UIView.animate(withDuration: 0.0) {self.cropsTableView.isHidden = true}}
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
 
}

    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               if (tableView == cropsTableView){
                   return crops.count
               }
               else if(tableView == stationsTableView){
                   return self.StationsWithGDDData.count
               }
               else if(tableView == resultsTableView){
                return selectedStationGDDData.stationDailyGDDData?.count ?? 0
                }
               return 0
           }
          func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
              let cell =   tableView.dequeueReusableCell(withIdentifier: "Cell",for:indexPath)
              if( tableView == cropsTableView){
                  cell.textLabel?.text = String( crops[indexPath.row])
              }
              else if (tableView == stationsTableView){
                  cell.textLabel?.text = String(StationsWithGDDData[indexPath.row].station!)}
              else if (tableView == resultsTableView){
                let df = DateFormatter()
                df.dateFormat = "MMM dd"
                let dateString = df.string(from: selectedStationGDDData.stationDailyGDDData![indexPath.row].date!)
                cell.textLabel?.text = dateString + "\t \t \t" + (NSString(format: "%.2f",selectedStationGDDData.stationDailyGDDData![indexPath.row].gdd!) as String)
            }
              return cell
          }
         
          
          func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
              if(tableView == cropsTableView){
                  selectCrop.setTitle(self.crops[indexPath.row], for: .normal)
                  animate(toggle: false)
              }
              else if(tableView == stationsTableView){
                selectedStation.isEnabled = true
                selectedStation.setTitle("Station: "+self.StationsWithGDDData[indexPath.row].station!, for: .normal)
                selectedStationGDDData = StationsWithGDDData[indexPath.row]
                animateResults(toggle: false)
                resultsTableView.reloadData()
                resultsTableView.isHidden = false
                resultsTableView.isEditing = false
                self.CumulativeGdd.backgroundColor = UIColor.orange//self.APPHEADER.backgroundColor
                self.CumulativeGdd.text = "Cumulative GDD:\t" + (NSString(format: "%.2f",selectedStationGDDData.stationCumulativeGDD!) as String)
                let df = DateFormatter()
                df.dateFormat = "MMM dd"
                self.usingRange.text = "Using data from " + df.string(from: (stationsData[indexPath.row].stationData?.first?.date)!) + " to " + df.string(from: (stationsData[indexPath.row].stationData?.last?.date)!)
            }
            self.CumulativeGdd.isHidden = false
            self.usingRange.isHidden = false
          }
}
