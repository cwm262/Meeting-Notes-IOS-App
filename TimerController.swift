//
//  TimerController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 12/11/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import Foundation

class TimerController {
    
    class func calculate(duration: Int32) -> String{
        var durationString = ""
        if duration == 60 {
            durationString = "1 min"
        }else if duration > 60 && duration <= 3600 {
            let numMinutes = duration / 60
            durationString = "\(numMinutes) min"
        }else if duration > 3600 {
            let numHours = duration / 3600
            let numMinutes = (duration % 3600) / 60
            durationString = "\(numHours) hr \(numMinutes) min"
        }
        
        return durationString
    }
}
