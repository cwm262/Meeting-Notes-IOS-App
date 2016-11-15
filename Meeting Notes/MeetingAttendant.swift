//
//  MeetingAttendant.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/8/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import Foundation

class MeetingAttendant {
    var givenName: String
    var familyName: String
    var email: String
    
    init(givenName: String, familyName: String, email: String){
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
    }
}
