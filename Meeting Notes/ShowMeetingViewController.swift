//
//  MeetingViewController.swift
//  Meeting Notes
//
//  Created by Ben Friedman on 11/16/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class ShowMeetingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var metaDataView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var descriptionField: UILabel!
    @IBOutlet weak var currentAgendaLabel: UILabel!
    @IBOutlet weak var currentTimerLabel: UILabel!
    
    @IBOutlet weak var agendaTableView: UITableView!
    @IBOutlet weak var timerBtn: UIButton!
    
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?
    var meetingAttendants: [Attendant]?
    var duration: Int32 = 0
    
    var alert = UIAlertController()
    var cancelAction = UIAlertAction()
    var timer: Int = 0
    var currentAgenda = 0
    var meetingBegin = false
    var checkForTableViewTransition = false
    
    override func viewWillAppear(_ animated: Bool) {
        let border = CALayer()
        border.frame = CGRect.init(x: 0, y: self.metaDataView.frame.height - 1.0, width: self.metaDataView.frame.width, height: 1.0)
        border.backgroundColor = UIColor.blue.cgColor
        self.metaDataView.layer.addSublayer(border)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //metaDataView.layer.borderWidth = 1
        //metaDataView.layer.borderColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
        //participantTableView.allowsSelection = false
        
        if let meeting = meeting {
            title = meeting.title
            locationLabel.text = meeting.location
            descriptionField.text = meeting.desc
            
            let startDate = meeting.startTime as! Date
            let startDateString = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .short)
            
            startLabel.text = "\(startDateString)"
            durationLabel.text = "0 hr 0 min"
            
            
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
            field.text = "1 min"
        }else if duration > 60 && duration < 3600 {
            let numMinutes = duration / 60
            field.text = "\(numMinutes) min"
        }else if duration > 3600 {
            let numHours = duration / 3600
            let numMinutes = (duration % 3600) / 60
            let hourStr = "hr"
            let minuteStr = "min"
            field.text = "\(numHours) \(hourStr) \(numMinutes) \(minuteStr)"
        }
    }
    
    @IBAction func startTimer(_ sender: Any) {
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func showAgenda(indexPath: IndexPath) {
        
        if let agenda = meetingAgendas?[indexPath.row] {
            
            alert = UIAlertController(title: "\(agenda.title!)", message: "\(agenda.task!)", preferredStyle: .alert)
            cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: {
                (action) in
                self.agendaTableView.cellForRow(at: indexPath)?.isSelected = false
            })
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
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
        
//        if tableView == self.participantTableView {
//            count = meetingAttendants?.count
//        }
        
        return count!
    }
    
    func selectAgenda(indexPath: IndexPath){
        if let agenda = meetingAgendas?[indexPath.row] {
            currentAgendaLabel.text = agenda.title
            currentTimerLabel.text = timeFormatted(totalSeconds: Int(agenda.duration))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.agendaTableView {
            selectAgenda(indexPath: indexPath)
            //showAgenda(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.agendaTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "agendaCell", for: indexPath)
            cell?.textLabel?.text = meetingAgendas?[indexPath.row].title
            if let duration = meetingAgendas?[indexPath.row].duration {
                if duration == 60 {
                    cell?.detailTextLabel?.text = "1 min"
                }else if duration > 60 && duration < 3600 {
                    let numMinutes = duration / 60
                    cell?.detailTextLabel?.text = "\(numMinutes) min"
                }else if duration > 3600 {
                    let numHours = duration / 3600
                    let numMinutes = (duration % 3600) / 60
                    cell?.detailTextLabel?.text = "\(numHours) hr \(numMinutes) min"
                }
            }
            
        }
        
//        if tableView == self.participantTableView {
//            cell = tableView.dequeueReusableCell(withIdentifier: "viewParticipantCell", for: indexPath)
//            let givenName = meetingAttendants?[indexPath.row].givenName
//            let familyName = meetingAttendants?[indexPath.row].familyName
//            let email = meetingAttendants?[indexPath.row].email
//            let titleString: String?
//            if let givenName = givenName, let familyName = familyName {
//                titleString = givenName + " " + familyName
//                cell?.textLabel?.text = titleString
//            }
//            if let email = email {
//                cell?.detailTextLabel?.text = email
//            }
//        }
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNotes" {
            let notesViewController = segue.destination as! NotesViewController
            if let meeting = meeting {
                notesViewController.notes = meeting.notes
                notesViewController.meeting = meeting
            }
            
        }
    }
    
    
}
