//
//  weatherData.swift
//  GDD Clculato Aq0r
// `
//  Created by Karthik Talakanti on 1/23/20.
//  Copyright © 2020 Karthik Talakanti. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

protocol weatherDataDelegate {
    
    func itemsDownloaded(response : [stations])
    }

class weatherData: NSObject {
    var delegate:weatherDataDelegate?
        
    func getItems(startDate: Date, endDate: Date, zipCode: String)  {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let startdate = dateFormatter.string(from: startDate)
                    let enddate = dateFormatter.string(from: endDate)
                    // let token = "JlQVeGrFotXwFFeRAvVKpbFJXBlGzrwa"
                     let datacategoryid = "TEMP"
                     let datatypeid = "TMIN,TMAX"
                     let locationid = "ZIP:"+zipCode
                     let datasetid = "GHCND"
                     let units = "standard"
                     let limit = "999"
            let parameters = ["datacategoryid": datacategoryid,"datatypeid":datatypeid,"locationid":locationid,"datasetid":datasetid,"startdate":startdate,"enddate":enddate,"units":units,"limit":limit]
            let headers: HTTPHeaders = [
                "token": "JlQVeGrFotXwFFeRAvVKpbFJXBlGzrwa",
                "Accept": "application/json"]
          
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd,yyyy"
            
            let dateF = DateFormatter()
            dateF.locale = Locale(identifier: "en_US_POSIX")
            dateF.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateF.isLenient = true
            dateFormatter.isLenient = true
            let decoder = JSONDecoder()
            let request = AF.request("https://www.ncdc.noaa.gov/cdo-web/api/v2/data?", parameters: parameters, headers: headers)
            request.response{ (responseData) in
            guard let data = responseData.data else {return}
                var receivedData = [stations]()
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            do {
                let root = try decoder.decode(Root.self, from: data)
                if(root.metadata?.resultset?.count ?? 0 >= 2){
                    let res = root.results
                    let grouped = Dictionary(grouping: res!) { (record) -> String in
                        return record.station!
                    }
                    for keys  in grouped.keys {
                        var dailytemps = [dailyData]()
                        let sorted = Dictionary(grouping: grouped[keys]!) { (ddd) -> String in
                            return ddd.date!
                        }
                        var gddCount: Int = 0;
                        for dates in sorted.keys{
                            let isoDate = dates
                            let date = dateFormatter.date(from:isoDate)!
                            var Tmin: Float = 0.0; var Tmax : Float = 0.0; var Tsum :Float = 0.0;
                            var numReadingsForDay = 0
                            for l in sorted[dates]!{
                                if l.datatype == "TMIN"{ Tsum += l.value ?? 0.0 ; Tmin = l.value ?? 0.0; numReadingsForDay += 1 }
                                else if l.datatype == "TMAX"{ Tsum += l.value ?? 0.0 ;Tmax = l.value ?? 0.0 ; numReadingsForDay += 1 }
                                if numReadingsForDay == 2 {
                                    dailytemps.append(dailyData(date:  date, tmax: Tmax, tmin: Tmin, tavg: Tsum/2.0))
                                if (Tsum/2.0 >= 40.0) {
                                    gddCount += 1
                                }
                                }
                            }
                          }
                        dailytemps.sort(by: { $0.date!.compare($1.date!) == .orderedAscending})
                        receivedData.append(stations(station: keys, stationData: dailytemps, stationGDDCount: gddCount))
                    }
                }
                    DispatchQueue.main.async {
                    //pass the data back to delegate
                    self.delegate?.itemsDownloaded(response: receivedData)
                }
            }catch{
                print("decoding error \(error)")
            }
        }
    }
}
