//
//  weather.swift
//  GDD Clculator
//
//  Created by Karthik Talakanti on 5/3/20.
//  Copyright © 2020 Karthik Talakanti. All rights reserved.
//

import Foundation

struct stationsGDD{
    var station : String?
    var stationDailyGDDData : [dailyGDD]?
    var stationCumulativeGDD : Float?
}

struct dailyGDD {
    var date : Date?
    var gdd : Float?
}


struct stations{
    var station : String?
    var stationData : [dailyData]?
    var stationGDDCount : Int?
}

struct dailyData {
    var date : Date?
    let tmax : Float?
    let tmin : Float?
    var tavg : Float?
}


struct Root : Decodable {
    let metadata : metadata?
    let results : [weather]?
}
struct metadata : Decodable {

    let resultset :resultset?

}
struct resultset : Decodable {
    enum CodingKeys : String, CodingKey {
            case offset = "offset"
            case count = "count"
            case limit = "limit"
    }
    let offset : Int?
    let count : Int?
    let limit : Int?
}

struct results : Decodable {

//    let weather :[weather]?
    let date : String?
    let datatype : String?
    let station : String?
    let attributes : String?
    let value : String?
    
    
    enum CodingKeys : String, CodingKey{
         case date = "date"
         case datatype = "datatype"
         case station = "station"
         case attributes = "attributes"
         case value = "value"
    }
    
    
}


struct weather : Decodable{
    let date : String?
    let datatype : String?
    let station : String?
    let attributes : String?
    let value : Float?
    
    
    enum CodingKeys : String, CodingKey{
         case date = "date"
         case datatype = "datatype"
         case station = "station"
         case attributes = "attributes"
         case value = "value"
    }
}
