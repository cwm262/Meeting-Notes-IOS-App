//
//  MeetingViewController.swift
//  Meeting Notes
//
//  Created by Ben Friedman on 11/16/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class ShowMeetingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    

    @IBOutlet weak var currentAgendaLabel: UILabel!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var currentTimerLabel: UILabel! {
        didSet {
            currentTimerLabel.font = currentTimerLabel.font.monospacedDigitFont
        }
    }
    
    @IBOutlet weak var metaDataTableView: UITableView!
    @IBOutlet weak var agendaTableView: UITableView!
    
    @IBOutlet weak var timerStartBtn: UIButton!
    @IBOutlet weak var timerPauseBtn: UIButton!
    @IBOutlet weak var timerResetBtn: UIButton!
    
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
    
    var metaLabels = ["Location", "Date", "Description", "Duration", "Participants"]
    var metaData = [String]()
    var durText: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        timerStartBtn.isEnabled = false
        timerPauseBtn.isEnabled = false
        currentAgendaLabel.text = "None"
        currentAgendaLabel.isEnabled = false
        currentTimerLabel.text = "00:00:00"
        currentTimerLabel.isEnabled = false
        notesField.isEditable = false
        navigationController?.toolbar.isHidden = true
        notesField.alpha = 0.50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meeting = meeting {
            title = meeting.title
            
            if let participants = meeting.attendants {
                numParticipants = participants.count
            }
            let startDate = meeting.startTime as! Date
            let startDateString = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .short)
            
            loadAgendas()
            loadAttendants()
            
            if (meetingAgendas?.count)! <= 3 {
                agendaTableView.isScrollEnabled = false
            }
            
            metaData.append("\(meeting.location!)")
            metaData.append("\(startDateString)")
            metaData.append("\(meeting.desc!)")
            metaData.append(durText)
            metaData.append("\(numParticipants)")
    
            
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        runningTimer = false
        agendaTimer.invalidate()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if let agendas = meetingAgendas {
            if agendas.count > 0 {
                meetingAgendas?[currentAgenda].notes = notesField.text
                DatabaseController.saveContext()
            }
        }
        navigationController?.toolbar.isHidden = false
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
                calculateAndSetDuration(duration: duration)
                
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
    
    
    func calculateAndSetDuration(duration: Int32){
        if duration == 60 {
            durText = "1 min"
        }else if duration > 60 && duration <= 3600 {
            let numMinutes = duration / 60
            durText = "\(numMinutes) min"
        }else if duration > 3600 {
            let numHours = duration / 3600
            let numMinutes = (duration % 3600) / 60
            let hourStr = "hr"
            let minuteStr = "min"
            durText = "\(numHours) \(hourStr) \(numMinutes) \(minuteStr)"
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
    
    @IBAction func resetTimer(_ sender: Any) {
        runningTimer = false
        agendaTimer.invalidate()
        timerArray[runningAgenda] = 0
        currentTimerLabel.text = "00:00:00"
        currentTimerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func countdown() {
        let time = meetingAgendas?[runningAgenda].duration
        
        timerArray[runningAgenda] += 1
        let timeString: String = timeFormatted(totalSeconds: timerArray[currentAgenda])
        currentTimerLabel.text = timeString
        if timerArray[runningAgenda] < Int(time!){
            currentTimerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
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
        
        if tableView == self.metaDataTableView {
            count = metaLabels.count
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
            notesField.text = agenda.notes
            notesField.isEditable = true
            notesField.alpha = 1
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
        
        if timerArray[runningAgenda] < Int(time!) || currentAgenda != runningAgenda{
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
        
        var cellReturn = UITableViewCell()
        
        if tableView == self.metaDataTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "metaCell", for: indexPath)
            cell.textLabel!.text = metaLabels[indexPath.row]
            cell.detailTextLabel!.text = metaData[indexPath.row]
            
            cellReturn = cell
        }
        
        if tableView == self.agendaTableView {
        
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
            
            cell.doneSwitch.tag = indexPath.row
            
            if let agendas = meetingAgendas {
                cell.doneSwitch.isOn = agendas[indexPath.row].isDone
            }
            cell.doneSwitch.addTarget(self, action: #selector(self.toggleAgendaState(_:)), for: .touchUpInside)
            
            cell.openAgendaModalBtn.tag = indexPath.row
            cell.openAgendaModalBtn.addTarget(self, action:#selector(self.openAgendaModal(_:)),for: .touchUpInside)
            
            
            if (meetingAgendas?[indexPath.row].isDone)! {
                //cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
            
            cellReturn = cell
        }
        
        return cellReturn
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView == self.agendaTableView {
            return 30
        }
        
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var header: String?
        
        
        if tableView == self.agendaTableView {
            header = "Agendas"
        }
        
        return header
    }
    
    @IBAction func toggleAgendaState(_ sender: AnyObject) {
        
        let cell = agendaTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! AgendaTableViewCell
        
        if let agenda = meetingAgendas?[sender.tag] {
            if cell.doneSwitch.isOn {
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
