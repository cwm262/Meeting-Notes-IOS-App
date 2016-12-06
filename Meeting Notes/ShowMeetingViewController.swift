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
    
    @IBOutlet weak var agendaTableView: UITableView!
    @IBOutlet weak var agendaIsDoneSwitch: UISwitch!
    
    @IBOutlet weak var timerStartBtn: UIButton!
    @IBOutlet weak var timerPauseBtn: UIButton!
    
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?
    var meetingAttendants: [Attendant]?
    var duration: Int32 = 0
    
    var alert = UIAlertController()
    var cancelAction = UIAlertAction()
    var timer: Int = 0
    var currentAgenda = 0
    var oldPath: IndexPath?
    var agendaTimer = Timer()
    var runningTimer = false
    var runningAgenda: Int = 0
    
    var timerArray: [Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        agendaIsDoneSwitch.isEnabled = false
        timerStartBtn.isEnabled = false
        timerPauseBtn.isEnabled = false
        currentAgendaLabel.text = "None"
        currentAgendaLabel.isEnabled = false
        currentTimerLabel.text = "00:00:00"
        currentTimerLabel.isEnabled = false
        
        let border = CALayer()
        border.frame = CGRect.init(x: 0, y: self.metaDataView.frame.height - 1.0, width: self.metaDataView.frame.width, height: 1.0)
        border.backgroundColor = UIColor.blue.cgColor
        self.metaDataView.layer.addSublayer(border)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meeting = meeting {
            title = meeting.title
            locationLabel.text = meeting.location
            descriptionField.text = meeting.desc
            
            let startDate = meeting.startTime as! Date
            let startDateString = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .short)
            
            startLabel.text = "\(startDateString)"
            durationLabel.text = "0 hr 0 min"
            notesField.text = meeting.notes
            
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
                    timerArray.append(Int(currentAgenda.duration))
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
        if timerArray[runningAgenda] > 0 {
            timerArray[runningAgenda] -= 1
            let timeString: String = timeFormatted(totalSeconds: timerArray[currentAgenda])
            currentTimerLabel.text = timeString
        } else {
            agendaTimer.invalidate()
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
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let oldPath = oldPath {
            tableView.cellForRow(at: oldPath)?.isSelected = false
        }
        oldPath = nil
        
        if tableView == self.agendaTableView {
            selectAgenda(indexPath: indexPath)
            
        }
        timerStartBtn.isEnabled = true
        timerPauseBtn.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        timerStartBtn.isEnabled = true
        timerPauseBtn.isEnabled = true
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "agendaCell", for: indexPath) as! AgendaTableViewCell
        
        cell.titleLabel.text = meetingAgendas?[indexPath.row].title
        
        if let duration = meetingAgendas?[indexPath.row].duration {
            if duration == 60 {
                cell.durationLabel.text = "1 min"
            }else if duration > 60 && duration < 3600 {
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
