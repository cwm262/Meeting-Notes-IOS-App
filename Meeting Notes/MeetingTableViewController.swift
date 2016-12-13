//
//  MeetingTableViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson, Ben Friedman on 11/1/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData

class MeetingTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Meeting Variables

    var meeting: Meeting?
    var duration: Int32 = 0
    var meetingSaved: Bool = false
    var context: NSManagedObjectContext?
    var activeTextField: UITextField? = nil
    
    //MARK: IBOutlets

    @IBOutlet weak var startTimeLabel: UILabel! {
        didSet {
            startTimeLabel.font = startTimeLabel.font.monospacedDigitFont
        }
    }
    
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var durationField: UILabel!
    @IBOutlet weak var agendaCountLabel: UILabel!
    @IBOutlet weak var attendantCountLabel: UILabel!
    
    @IBOutlet var textFields: [UITextField]!
    //MARK: Booleans for Whether or Not Section is Expanded
    
    var startDatePickerHidden: Bool = true
    var descTextHidden: Bool = true
    
    var descLoaded: Bool = false
    var dateLoaded: Bool = false
    
    //MARK: Dynamic cells
    
    var descCell = UITableViewCell()
    var dateCell = UITableViewCell()
    
    //MARK: DidLoad and WillAppear Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for field in textFields {
            field.delegate = self
        }
        
        title = "New Meeting"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MeetingTableViewController.saveMeeting))
        titleField.borderStyle = .none
        locationField.borderStyle = .none
        
        context = DatabaseController.getContext()
        
        if let meeting = meeting {
            meetingSaved = true
            navigationItem.rightBarButtonItem?.title = "Save"
            title = "Edit Meeting"
            titleField.text = meeting.title
            locationField.text = meeting.location
            descriptionField.text = meeting.desc
            if meeting.duration > 0 {
                durationField.text = TimerController.calculate(duration: meeting.duration)
            }
            
            if (meeting.agendas?.count)! > 0 {
                agendaCountLabel.text = "\(meeting.agendas?.count)"
            }
            
            if (meeting.attendants?.count)! > 0 {
                attendantCountLabel.text = "\(meeting.attendants?.count)"
            }
            let str = meeting.desc?.characters
            if let str = str {
                var descLbl = ""
                var total = 0
                for index in str {
                    total += 1
                    if total < 25 {
                        descLbl.append(index)
                    }
                    else if total == 25 {
                        descLbl += "..."
                    }
                }
                descriptionLabel.text = descLbl
            }
            startTimeDatePicker.date = meeting.startTime as! Date
        
        }else {
            if let context = context {
                let desc = NSEntityDescription.entity(forEntityName: "Meeting", in: context)
                meeting = Meeting(entity: desc!, insertInto: context)
                DatabaseController.saveContext()
            }
        }
        
        if descriptionField.text.characters.count == 0 {
            descriptionField.text = "Description"
            descriptionField.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        }
        
        datePickerChanged(label: startTimeLabel, datePicker: startTimeDatePicker)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !meetingSaved, let meeting = meeting {
            DatabaseController.getContext().delete(meeting)
            DatabaseController.saveContext()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        if let agendas = meeting?.agendas, agendas.count > 0 {
            duration = 0
            for agenda in agendas {
                duration += (agenda as AnyObject).duration
            }
            durationField.text = TimerController.calculate(duration: duration)
            agendaCountLabel.text = "\(agendas.count)"
        } else {
            durationField.text = "No Agendas"
            agendaCountLabel.text = "None"
        }
        
        if let attendants = meeting?.attendants, attendants.count > 0 {
            attendantCountLabel.text = "\(attendants.count)"
        } else {
            attendantCountLabel.text = "None"
        }
    
        navigationController?.toolbar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveMeeting(){
        meetingSaved = true
        meeting?.title = titleField.text
        meeting?.location = locationField.text
        if descriptionField.text == "Description" {
            meeting?.desc = ""
        } else {
            meeting?.desc = descriptionField.text
        }
        meeting?.startTime = startTimeDatePicker.date as NSDate?
        if let agendas = meeting?.agendas {
            duration = 0
            for agenda in agendas {
                duration += (agenda as AnyObject).duration
            }
            meeting?.duration = duration
        }
        DatabaseController.saveContext()

        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: Datepicker Functions
    
    @IBAction func startDatePickerValueChanged(_ sender: Any) {
        datePickerChanged(label: startTimeLabel, datePicker: startTimeDatePicker)
        
    }
    
    func datePickerChanged(label: UILabel, datePicker: UIDatePicker){
        label.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .medium, timeStyle: .short)
    }
    
    //MARK: Functions that Control Whether Section is Expanded or Not on Table
    
    func fieldViewToggled(_ whichField: inout Bool){
        whichField = !whichField
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 || (indexPath.section == 2 && indexPath.row == 2) {
            tableView.cellForRow(at: indexPath)?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            dateCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))!
            dateLoaded = true
            startTimeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&startDatePickerHidden)
            descriptionField?.resignFirstResponder()
            activeTextField?.resignFirstResponder()
            if !descTextHidden {
                fieldViewToggled(&descTextHidden)
            }
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            descCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))!
            descLoaded = true
            descriptionLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&descTextHidden)
            descriptionField?.resignFirstResponder()
            activeTextField?.resignFirstResponder()
            if !startDatePickerHidden {
                fieldViewToggled(&startDatePickerHidden)
            }
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            var animate: Bool = true
            if meeting?.agendas?.count == 0 || meeting?.agendas == nil {
                animate = false
            } else {
                animate = true
            }
            let agendaViewController = storyboard?.instantiateViewController(withIdentifier: "agendaViewController") as! AgendaViewController
            agendaViewController.meeting = self.meeting
            meetingSaved = true
            navigationController?.pushViewController(agendaViewController, animated: animate)
        }
        
        if indexPath.section == 4 && indexPath.row == 0 {
            var animate: Bool = true
            if meeting?.attendants?.count == 0 || meeting?.attendants == nil {
                animate = false
            } else {
                animate = true
            }
            let attendantViewController = storyboard?.instantiateViewController(withIdentifier: "attendantViewController") as! AttendantViewController
            attendantViewController.meeting = self.meeting
            attendantViewController.editingAttendants = true
            meetingSaved = true
            navigationController?.pushViewController(attendantViewController, animated: animate)
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if startDatePickerHidden && indexPath.section == 2 && indexPath.row == 1 {
            if dateLoaded {
                dateCell.isSelected = false
            }
            startTimeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else if descTextHidden && indexPath.section == 1 && indexPath.row == 1{
            if descLoaded {
                descCell.isSelected = false
            }
            descriptionLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !startDatePickerHidden {
            fieldViewToggled(&startDatePickerHidden)
        }
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
            textView.text = "Description"
            textView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        }
    }
    
    //MARK: Functions that Deal with TextViews and TextFields
    func textViewDidChange(_ textView: UITextView) {
        switch (textView) {
            case descriptionField:
                if textView.text.characters.count < 1 {
                    descriptionLabel.text = "No Description"
                }
                else if textView.text.characters.count > 30 {
                    break
                }
                else if textView.text.characters.count < 30 {
                    descriptionLabel.text = textView.text
                }
                else{
                    descriptionLabel.text = textView.text + "..."
                }
            default: break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterCountLimit = 20
        
        let startingLength = titleField.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
    
    
    //Dismiss keyboard functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !startDatePickerHidden {
            fieldViewToggled(&startDatePickerHidden)
        }
        if !descTextHidden {
            fieldViewToggled(&descTextHidden)
        }
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeTextField?.resignFirstResponder()
        
        return true
    }
    
    //MARK: Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        meetingSaved = true
        if (segue.identifier == "attendantViewSegue") {
            let attendantViewController = segue.destination as! AttendantViewController
            attendantViewController.meeting = self.meeting
        }else if segue.identifier == "agendaViewSegue" {
            let agendaViewController = segue.destination as! AgendaViewController
            agendaViewController.meeting = self.meeting
        }
    }
    
}
