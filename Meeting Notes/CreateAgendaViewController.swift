//
//  AgendaViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/13/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData

protocol AgendaSharing {
    func shareAgenda(agenda: Agenda?)
}

class CreateAgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var agenda: Agenda?
    var meetingTableController: AgendaSharing?
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?

    @IBOutlet weak var countdownTimer: UIDatePicker!
    @IBOutlet weak var taskTextView: UITextView!
    
    @IBOutlet weak var titleTableView: UITableView!
    @IBOutlet weak var timerTableView: UITableView!
    
    var timerHidden = true
    var durCell = UITableViewCell()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTextView.layer.borderWidth = 1
        taskTextView.layer.borderColor = UIColor(ciColor: CIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)).cgColor
        
        taskTextView.textContainerInset = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
        
        taskTextView.text = "Task"
        taskTextView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateAgendaViewController.addAgenda))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAgenda(){
        let titleCell = titleTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CreateAgendaTitleTableViewCell
        let timerCell = timerTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! CreateAgendaTimerTableViewCell
        
        let context = DatabaseController.getContext()
        let desc = NSEntityDescription.entity(forEntityName: "Agenda", in: context)
        agenda = Agenda(entity: desc!, insertInto: context)
        agenda?.setValue(titleCell.titleField.text, forKey: "title")
        if taskTextView.text == "Task" {
            agenda?.setValue("", forKey: "task")
        } else {
            agenda?.setValue(taskTextView.text, forKey: "task")
        }
        let duration = timerCell.countdownTimer.countDownDuration
        agenda?.setValue(duration, forKey: "duration")
        if let meeting = meeting, let agenda = agenda {
            meeting.addToAgendas(agenda)
            DatabaseController.saveContext()
            self.meetingTableController?.shareAgenda(agenda: nil)
        }else{
            self.meetingTableController?.shareAgenda(agenda: agenda)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.timerTableView {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.timerTableView {
        
            if timerHidden && indexPath.row == 1 {
                durCell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                durCell.isSelected = false
                return 0
            } else if !timerHidden && indexPath.row == 1 {
                return 216
            }
        }
        
        return tableView.rowHeight
    }
    
    func fieldViewToggled(_ whichField: inout Bool){
        whichField = !whichField
        self.timerTableView.beginUpdates()
        self.timerTableView.endUpdates()
        taskTextView?.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.timerTableView {
            
            if indexPath.row == 0 {
                let durCell = tableView.cellForRow(at: indexPath)
                durCell?.detailTextLabel?.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                fieldViewToggled(&timerHidden)
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if tableView == self.titleTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! CreateAgendaTitleTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        if tableView == self.timerTableView {
            if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "timerCell", for: indexPath) as! CreateAgendaTimerTableViewCell
            } else if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "durationCell", for: indexPath)
                cell.detailTextLabel?.text = "1 min"
                durCell = cell
            }
        }
        
        return cell
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != UIColor.black {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let strArr = Array(textView.text.characters)
        var allSpaces = true
 
        for letter in strArr {
            if letter != " " {
                allSpaces = false
            }
        }
        
        if strArr.count == 0 || allSpaces {
            textView.text = "Task"
            textView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        }
    }
    
    func calculateAndSetDuration(duration: Int32){
        
        if duration == 60 {
            durCell.detailTextLabel?.text = "1 min"
        }else if duration > 60 && duration < 3600 {
            let numMinutes = duration / 60
            durCell.detailTextLabel?.text = "\(numMinutes) min"
        }else if duration > 3600 {
            let numHours = duration / 3600
            let numMinutes = (duration % 3600) / 60
            durCell.detailTextLabel?.text = "\(numHours) hr \(numMinutes) min"
        }
    }
    
    
    @IBAction func changedTimerVal(_ sender: Any) {
        let timerCell = timerTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! CreateAgendaTimerTableViewCell
        
        calculateAndSetDuration(duration: Int32(timerCell.countdownTimer.countDownDuration))
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
