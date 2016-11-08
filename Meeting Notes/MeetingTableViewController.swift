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
    
    var meeting: Meeting?
    var attendants = [Attendant]()

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    
    var startDatePickerHidden: Bool = true
    var endDatePickerHidden: Bool = true
    var descTextHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Meeting"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(MeetingTableViewController.saveMeeting))
        
        if let meeting = meeting {
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
            endTimeDatePicker.date = meeting.endTime as! Date
        }
        
        datePickerChanged(label: startTimeLabel, datePicker: startTimeDatePicker)
        datePickerChanged(label: endTimeLabel, datePicker: endTimeDatePicker)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func saveMeeting(){
        let context = getContext()
        if meeting == nil {
            meeting = Meeting(context: context)
        }
        if let meeting = meeting {
            meeting.title = titleField.text
            meeting.location = locationField.text
            meeting.desc = descriptionField.text
            meeting.startTime = startTimeDatePicker.date as NSDate?
            meeting.endTime = endTimeDatePicker.date as NSDate?
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        _ = navigationController?.popToRootViewController(animated: true)
    }

    
    @IBAction func startDatePickerValueChanged(_ sender: Any) {
        datePickerChanged(label: startTimeLabel, datePicker: startTimeDatePicker)
    }
    
    @IBAction func endDatePickerValueChanged(_ sender: Any) {
        datePickerChanged(label: endTimeLabel, datePicker: endTimeDatePicker)
    }
    
    @IBAction func importParticipant(_ sender: Any) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: [CNContact]) {
        for n in contact{
        
            let givenName: String? = n.givenName
            let familyName: String? = n.familyName
            let email: String? = n.emailAddresses.first?.value as String?
            
            if let givenName = givenName, let familyName = familyName, let email = email{
                let attendant = Attendant(givenName: givenName, familyName: familyName, email: email)
                attendants.append(attendant)
            }
        }
    }
    
    func datePickerChanged(label: UILabel, datePicker: UIDatePicker){
        label.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .medium, timeStyle: .short)
    }
    
    func fieldViewToggled(_ whichField: inout Bool){
        whichField = !whichField
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            startTimeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&startDatePickerHidden)
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            endTimeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&endDatePickerHidden)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            descriptionLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            fieldViewToggled(&descTextHidden)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if startDatePickerHidden && indexPath.section == 2 && indexPath.row == 1 {
            startTimeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else if endDatePickerHidden && indexPath.section == 3 && indexPath.row == 1 {
            endTimeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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
    

}
