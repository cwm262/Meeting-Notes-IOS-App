//
//  MeetingViewController.swift
//  Meeting Notes
//
//  Created by Ben Friedman on 11/16/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class ShowMeetingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var agendaTableView: UITableView!
    @IBOutlet weak var participantTableView: UITableView!
    
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?
    var meetingAttendants: [Attendant]?
    var duration: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meeting = meeting {
            titleLabel.text = meeting.title
            locationLabel.text = meeting.location
            descriptionTextView.text = meeting.desc
            
            let startDate = meeting.startTime as! Date
            let startDateString = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .short)
            
            startLabel.text = "\(startDateString)"
            durationLabel.text = "0:00"
            
            
        }
        
        loadAgendas()
        loadAttendants()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAgendas(){
        if let meeting = meeting {
            if let agendas = meeting.agendas {
                meetingAgendas = [Agenda]()
                duration = 0
                for i in agendas {
                    let currentAgenda = i as! Agenda
                    meetingAgendas!.append(currentAgenda)
                    duration += currentAgenda.duration
                }
                calculateAndSetDuration(duration: duration, field: durationLabel)
            }
        }
    }
    
    func loadAttendants(){
        if let meeting = meeting {
            if let attendants = meeting.attendants {
                meetingAttendants = [Attendant]()
                for i in attendants {
                    let currentAttendant = i as! Attendant
                    meetingAttendants!.append(currentAttendant)
                }
            }
        }
    }
    
    func calculateAndSetDuration(duration: Int32, field: UILabel){
        if duration == 60 {
            field.text = "1 minute"
        }else if duration > 60 && duration < 3600 {
            let numMinutes = duration / 60
            field.text = "\(numMinutes) minutes"
        }else if duration > 3600 {
            let numHours = duration / 3600
            let numMinutes = (duration % 3600) / 60
            var hourStr = ""
            var minuteStr = ""
            if numHours == 1 {
                hourStr = "hour"
            }else{
                hourStr = "hours"
            }
            if numMinutes == 1 {
                minuteStr = "minute"
            }else {
                minuteStr = "minutes"
            }
            field.text = "\(numHours) \(hourStr), \(numMinutes) \(minuteStr)"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.agendaTableView {
            count = meetingAgendas?.count
        }
        
        if tableView == self.participantTableView {
            count = meetingAttendants?.count
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.agendaTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "agendaCell", for: indexPath)
            cell?.textLabel?.text = meetingAgendas?[indexPath.row].title
            if let duration = meetingAgendas?[indexPath.row].duration {
                if duration == 60 {
                    cell?.detailTextLabel?.text = "1 minute"
                }else if duration > 60 && duration < 3600 {
                    let numMinutes = duration / 60
                    cell?.detailTextLabel?.text = "\(numMinutes) minutes"
                }else if duration > 3600 {
                    let numHours = duration / 3600
                    let numMinutes = (duration % 3600) / 60
                    cell?.detailTextLabel?.text = "\(numHours) hours, \(numMinutes) minutes"
                }
            }
        }
        
        if tableView == self.participantTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "viewParticipantCell", for: indexPath)
            let givenName = meetingAttendants?[indexPath.row].givenName
            let familyName = meetingAttendants?[indexPath.row].familyName
            let email = meetingAttendants?[indexPath.row].email
            let titleString: String?
            if let givenName = givenName, let familyName = familyName {
                titleString = givenName + " " + familyName
                cell?.textLabel?.text = titleString
            }
            if let email = email {
                cell?.detailTextLabel?.text = email
            }
        }
        
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
