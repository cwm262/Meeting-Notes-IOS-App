//
//  MeetingTableViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson, Ben Friedman on 11/1/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData

class MeetingTableViewController: UITableViewController, UITextFieldDelegate {
    
    var meeting: Meeting?

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    var startDatePickerHidden: Bool = true
    var endDatePickerHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Meeting"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(MeetingTableViewController.saveMeeting))
        
        if let meeting = meeting {
            title = "Edit Meeting"
            titleField.text = meeting.title
            locationField.text = meeting.location
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
    
    func datePickerChanged(label: UILabel, datePicker: UIDatePicker){
        label.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .medium, timeStyle: .short)
    }
    
    func toggleDatePicker(_ whichDatePicker: inout Bool){
        whichDatePicker = !whichDatePicker
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            startTimeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            toggleDatePicker(&startDatePickerHidden)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            endTimeLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            toggleDatePicker(&endDatePickerHidden)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if startDatePickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            startTimeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else if endDatePickerHidden && indexPath.section == 2 && indexPath.row == 1 {
            endTimeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
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
