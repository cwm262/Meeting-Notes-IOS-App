//
//  MeetingTableViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson, Ben Friedman on 11/1/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class MeetingTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, CNContactPickerDelegate {
    
    //MARK: Meeting Variables

    var meeting: Meeting?
    var meetingAttendants: [MeetingAttendant]?
    var attendantsToBeDeleted: [Attendant]?
    var agendasToBeDeleted: [Agenda]?
    var duration: Int32 = 0
    var meetingSaved: Bool = false
    var context: NSManagedObjectContext?
    
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
            durationField.text = TimerController.calculate(duration: meeting.duration)
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
        navigationController?.toolbar.isHidden = false
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadAttendants(){
        if let meeting = meeting{
            if let attendants = meeting.attendants {
                meetingAttendants = [MeetingAttendant]()
                for attendant in attendants {
                    let currentAttendant = attendant as! Attendant
                    let givenName = currentAttendant.givenName
                    let familyName = currentAttendant.familyName
                    let email = currentAttendant.email
                    let meetingAttendant = MeetingAttendant(givenName: givenName!, familyName: familyName!, email: email!)
                    meetingAttendants!.append(meetingAttendant)
                }
            }
        }
        
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
    
    //MARK: Import a Contact from ContactPicker
    
    @IBAction func importParticipant(_ sender: Any) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts{
            let givenName: String? = contact.givenName
            let familyName: String? = contact.familyName
            let email: String? = contact.emailAddresses.first?.value as String?
            
            if let givenName = givenName, let familyName = familyName, let email = email{
                if let currAttendants = meetingAttendants{
                    var alreadyAdded = false
                    for meetingAttendant in currAttendants{
                        if meetingAttendant.email == email {
                            alreadyAdded = true
                        }
                    }
                    if(!alreadyAdded){
                        let newAttendant = MeetingAttendant(givenName: givenName, familyName: familyName, email: email)
                        meetingAttendants!.append(newAttendant)
                    }
                }else{
                    let newAttendant = MeetingAttendant(givenName: givenName, familyName: familyName, email: email)
                    meetingAttendants = [MeetingAttendant]()
                    meetingAttendants!.append(newAttendant)
                }
                
                let embeddedController: AttendantViewController = self.childViewControllers[1] as! AttendantViewController
                embeddedController.attendants = meetingAttendants
                embeddedController.attendantTableView.reloadData()
                
                let scrollEnabled = embeddedController.checkScroll()
                if scrollEnabled {
                    embeddedController.attendantTableView.flashScrollIndicators()
                }
                embeddedController.attendantTableView.isScrollEnabled = scrollEnabled
            }else{
                let alert = UIAlertController(title: "Contact Not Imported", message: "\(givenName ?? "") \(familyName ?? "") \(email ?? "") has not been added because the contact was missing either their first name, last name, or email.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(confirmAction)
                picker.dismiss(animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }
        }
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
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            descCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))!
            descLoaded = true
            descriptionLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&descTextHidden)
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
    
    //MARK: Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "attendantViewSegue") {
            loadAttendants()
            let attendantViewController = segue.destination as! AttendantViewController
            attendantViewController.attendants = meetingAttendants
        }else if segue.identifier == "agendaViewSegue" {
            meetingSaved = true
            let agendaViewController = segue.destination as! AgendaViewController
            agendaViewController.meeting = self.meeting
        }
    }

}
