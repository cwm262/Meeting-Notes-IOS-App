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

class MeetingTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, CNContactPickerDelegate, AgendaSharing {
    
    //MARK: Meeting Variables
    
    var meeting: Meeting?
    var meetingAttendants: [MeetingAttendant]?
    var meetingAgendas: [Agenda]?
    var attendantsToBeDeleted: [Attendant]?
    var agendasToBeDeleted: [Agenda]?
    var duration: Int32 = 0
    
    //MARK: IBOutlets

    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var durationField: UILabel!
    
    @IBOutlet weak var addParticipantBtn: UIBarButtonItem!
    //MARK: Booleans for Whether or Not Section is Expanded
    
    var startDatePickerHidden: Bool = true
    var descTextHidden: Bool = true
    
    //MARK: DidLoad and WillAppear Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Meeting"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(MeetingTableViewController.saveMeeting))
        titleField.borderStyle = .none
        locationField.borderStyle = .none
        
        if let meeting = meeting {
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationItem.rightBarButtonItem?.style = .done
            title = "Edit Meeting"
            titleField.text = meeting.title
            locationField.text = meeting.location
            descriptionField.text = meeting.desc
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
            

        }
        
        datePickerChanged(label: startTimeLabel, datePicker: startTimeDatePicker)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        let agendaController: AgendaViewController = self.childViewControllers[0] as! AgendaViewController
        agendaController.agendas = meetingAgendas
        agendaController.agendaTableView.reloadData()
        
        let scrollEnabled = agendaController.checkScroll()
        if scrollEnabled {
            agendaController.agendaTableView.flashScrollIndicators()
        }
        agendaController.agendaTableView.isScrollEnabled = scrollEnabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shareAgenda(agenda: Agenda?) {
        if let agenda = agenda {
            if self.meetingAgendas != nil {
                self.meetingAgendas!.append(agenda)
            }else{
                self.meetingAgendas = [Agenda]()
                self.meetingAgendas!.append(agenda)
            }
            duration += agenda.duration
            calculateAndSetDuration(duration: duration)
        }else{
            loadAgendas()
        }
        
        let agendaController: AgendaViewController = self.childViewControllers[0] as! AgendaViewController
        agendaController.agendas = meetingAgendas
        agendaController.agendaTableView.reloadData()
        
        
    }
    
    func calculateAndSetDuration(duration: Int32){
        if duration == 60 {
            durationField.text = "1 min"
        }else if duration > 60 && duration < 3600 {
            let numMinutes = duration / 60
            durationField.text = "\(numMinutes) min"
        }else if duration > 3600 {
            let numHours = duration / 3600
            let numMinutes = (duration % 3600) / 60
            durationField.text = "\(numHours) hr \(numMinutes) min"
        }
    }
    
    //MARK: Functions that Load from DB or Save to DB
    
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
                calculateAndSetDuration(duration: duration)
            }
        }
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
        let context = DatabaseController.getContext()
        if meeting == nil {
            let desc = NSEntityDescription.entity(forEntityName: "Meeting", in: context)
            meeting = Meeting(entity: desc!, insertInto: context)
        }
        if let meeting = meeting {
            meeting.title = titleField.text
            meeting.location = locationField.text
            meeting.desc = descriptionField.text
            meeting.startTime = startTimeDatePicker.date as NSDate?
            
            if let meetingAttendants = meetingAttendants{
                for meetingAttendant in meetingAttendants{
                    if let ma = meeting.attendants {
                        var alreadyAdded = false
                        for m in ma {
                            let curr = m as! Attendant
                            if curr.email == meetingAttendant.email {
                                alreadyAdded = true
                            }
                        }
                        if(!alreadyAdded){
                            let attendantDesc = NSEntityDescription.entity(forEntityName: "Attendant", in: context)
                            let attendant = Attendant(entity: attendantDesc!, insertInto: context)
                            attendant.setValue(meetingAttendant.givenName, forKey: "givenName")
                            attendant.setValue(meetingAttendant.familyName, forKey: "familyName")
                            attendant.setValue(meetingAttendant.email, forKey: "email")
                            
                            meeting.addToAttendants(attendant)
                        }
                    }else{
                        let attendantDesc = NSEntityDescription.entity(forEntityName: "Attendant", in: context)
                        let attendant = Attendant(entity: attendantDesc!, insertInto: context)
                        attendant.setValue(meetingAttendant.givenName, forKey: "givenName")
                        attendant.setValue(meetingAttendant.familyName, forKey: "familyName")
                        attendant.setValue(meetingAttendant.email, forKey: "email")
                        
                        meeting.addToAttendants(attendant)
                    }
                    
                }
                
            }
            if let meetingAgendas = meetingAgendas {
                if let savedAgendas = meeting.agendas as? Set<Agenda>, savedAgendas.count > 0 {
                    for meetingAgenda in meetingAgendas {
                        for savedAgenda in savedAgendas {
                            if savedAgenda === meetingAgenda {
                                savedAgenda.duration = meetingAgenda.duration
                                savedAgenda.task = meetingAgenda.task
                                savedAgenda.title = meetingAgenda.title
                            }else{
                                meeting.addToAgendas(meetingAgenda)
                            }
                        }
                    }
                }else{
                    for meetingAgenda in meetingAgendas {
                        meeting.addToAgendas(meetingAgenda)
                    }
                }
            }
            if let attendantsToBeDeleted = attendantsToBeDeleted {
                for attendantTBD in attendantsToBeDeleted {
                    meeting.removeFromAttendants(attendantTBD)
                }
            }
            if let agendasToBeDeleted = agendasToBeDeleted {
                for agendaTBD in agendasToBeDeleted {
                    meeting.removeFromAgendas(agendaTBD)
                }
            }
            DatabaseController.saveContext()
        }
        
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
            startTimeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&startDatePickerHidden)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            descriptionLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&descTextHidden)
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 4 && indexPath.row == 0 {
            
            if let attendants = meetingAttendants {
                let height = attendants.count * 32
                
                if height > 96 {
                    return 96
                } else {
                    return CGFloat(height)
                }
                
            } else {
                return 0
            }
            
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            
            if let agendas = meetingAgendas {
                let height = agendas.count * 32
                
                if height > 96 {
                    return 96
                } else {
                    return CGFloat(height)
                }
                
            } else {
                return 0
            }
            
        }
        
        if startDatePickerHidden && indexPath.section == 2 && indexPath.row == 1 {
            startTimeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else if descTextHidden && indexPath.section == 1 && indexPath.row == 1{
            descriptionLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
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
            loadAgendas()
            let agendaViewController = segue.destination as! AgendaViewController
            agendaViewController.agendas = meetingAgendas
            agendaViewController.meeting = self.meeting
        }else if segue.identifier == "createAgendaSegue" {
            let createAgendaViewController = segue.destination as! CreateAgendaViewController
            createAgendaViewController.meetingTableController = self
            createAgendaViewController.meeting = self.meeting
            createAgendaViewController.meetingAgendas = self.meetingAgendas
        }
    }
    

}
