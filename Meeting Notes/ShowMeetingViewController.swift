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
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var numberParticipantsField: UILabel!
    
    @IBOutlet weak var agendaTableView: UITableView!
    @IBOutlet weak var agendaIsDoneSwitch: UISwitch!
    
    @IBOutlet weak var timerStartBtn: UIButton!
    @IBOutlet weak var timerPauseBtn: UIButton!
    
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?
    var meetingAttendants: [Attendant]?
    var duration: Int32 = 0
    var numParticipants: Int = 0
    
    var alert = UIAlertController()
    var cancelAction = UIAlertAction()
    var timer: Int = 0
    var currentAgenda = 0
    var oldPath: IndexPath?
    var agendaTimer = Timer()
    var runningTimer = false
    var runningAgenda: Int = 0
    
    var timerArray: [Int] = []
    
    override func viewWillDisappear(_ animated: Bool) {
        runningTimer = false
        agendaTimer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        agendaIsDoneSwitch.isEnabled = false
        timerStartBtn.isEnabled = false
        timerPauseBtn.isEnabled = false
        currentAgendaLabel.text = "None"
        currentAgendaLabel.isEnabled = false
        currentTimerLabel.text = "00:00:00"
        currentTimerLabel.isEnabled = false
        notesField.isEditable = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meeting = meeting {
            title = meeting.title
            locationLabel.text = meeting.location
            descriptionField.text = meeting.desc
            
            if let participants = meeting.attendants {
                numParticipants = participants.count
            }
            let startDate = meeting.startTime as! Date
            let startDateString = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .short)
            
            startLabel.text = "\(startDateString)"
            durationLabel.text = "0 hr 0 min"
            numberParticipantsField.text = "\(numParticipants)"
            
        }
        
        loadAgendas()
        loadAttendants()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        meetingAgendas?[currentAgenda].notes = notesField.text
        DatabaseController.saveContext()
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
                    timerArray.append(0)
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
        }else if duration > 60 && duration <= 3600 {
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
        if !runningTimer {
            agendaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
            runningTimer = true
        }

        runningAgenda = currentAgenda
    }
    @IBAction func pauseTimer(_ sender: Any) {
        runningTimer = false
        agendaTimer.invalidate()
    }
    
    func countdown() {
        let time = meetingAgendas?[runningAgenda].duration
        if timerArray[runningAgenda] < Int(time!){
            timerArray[runningAgenda] += 1
            let timeString: String = timeFormatted(totalSeconds: timerArray[currentAgenda])
            currentTimerLabel.text = timeString
            currentTimerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            timerArray[runningAgenda] += 1
            let timeString: String = timeFormatted(totalSeconds: timerArray[currentAgenda])
            currentTimerLabel.text = timeString
            currentTimerLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        }
        
        if runningAgenda != currentAgenda {
            currentTimerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.agendaTableView {
            count = meetingAgendas?.count
        }
        
        return count!
    }
    
    func selectAgenda(indexPath: IndexPath){
        if let agenda = meetingAgendas?[indexPath.row] {
            currentAgendaLabel.text = agenda.title
            currentAgendaLabel.isEnabled = true
            currentAgenda = indexPath.row
            currentTimerLabel.text = timeFormatted(totalSeconds: timerArray[currentAgenda])
            currentTimerLabel.isEnabled = true
            agendaIsDoneSwitch.isOn = agenda.isDone
            agendaIsDoneSwitch.isEnabled = true
            notesField.text = agenda.notes
            notesField.isEditable = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let time = meetingAgendas?[runningAgenda].duration
        if let oldPath = oldPath {
            tableView.cellForRow(at: oldPath)?.isSelected = false
        }
        oldPath = nil
        
        if tableView == self.agendaTableView {
            selectAgenda(indexPath: indexPath)
        }
        timerStartBtn.isEnabled = true
        timerPauseBtn.isEnabled = true
        
        if timerArray[runningAgenda] < Int(time!){
            currentTimerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else if currentAgenda != runningAgenda{
            currentTimerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            currentTimerLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        meetingAgendas?[indexPath.row].notes = notesField.text
        DatabaseController.saveContext()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "agendaCell", for: indexPath) as! AgendaTableViewCell
        
        cell.titleLabel.text = meetingAgendas?[indexPath.row].title
        
        if let duration = meetingAgendas?[indexPath.row].duration {
            if duration == 60 {
                cell.durationLabel.text = "1 min"
            }else if duration > 60 && duration <= 3600 {
                let numMinutes = duration / 60
                cell.durationLabel.text = "\(numMinutes) min"
            }else if duration > 3600 {
                let numHours = duration / 3600
                let numMinutes = (duration % 3600) / 60
                cell.durationLabel.text = "\(numHours) hr \(numMinutes) min"
            }
        }
        
        cell.openAgendaModalBtn.tag = indexPath.row
        cell.openAgendaModalBtn.addTarget(self, action:#selector(self.openAgendaModal(_:)),for: .touchUpInside)
        
        
        if (meetingAgendas?[indexPath.row].isDone)! {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    @IBAction func toggleAgendaState(_ sender: Any) {
        if let agenda = meetingAgendas?[currentAgenda] {
            if agendaIsDoneSwitch.isOn {
                agenda.isDone = true
                runningTimer = false
                agendaTimer.invalidate()
            }else {
                agenda.isDone = false
            }
            DatabaseController.saveContext()
            agendaTableView.reloadData()
            oldPath = IndexPath(row: currentAgenda, section: 0)
            agendaTableView.cellForRow(at: oldPath!)?.isSelected = true
        }
    }
    
    @IBAction func openAgendaModal(_ sender: AnyObject){
        if let agenda = meetingAgendas?[sender.tag] {
            
            alert = UIAlertController(title: "\(agenda.title!)", message: "\(agenda.task!)", preferredStyle: .alert)
            cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
}
