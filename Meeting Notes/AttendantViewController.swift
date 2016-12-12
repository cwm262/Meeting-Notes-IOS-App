//
//  AttendantViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/11/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class AttendantViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactPickerDelegate {

    var meeting: Meeting?
    var attendants: [MeetingAttendant]?
    var attendantsToBeDeleted: [Attendant] = [Attendant]()
    
    @IBOutlet weak var attendantTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendantTableView.setEditing(true, animated: true)
        
        let addButton = UIBarButtonSystemItem.add
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: addButton, target: self, action: #selector(self.importParticipant))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: false)
        attendantTableView.reloadData()
    }
    
    func importParticipant() {
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
                if let currAttendants = attendants{
                    var alreadyAdded = false
                    for meetingAttendant in currAttendants{
                        if meetingAttendant.email == email {
                            alreadyAdded = true
                        }
                    }
                    if(!alreadyAdded){
                        let newAttendant = MeetingAttendant(givenName: givenName, familyName: familyName, email: email)
                        attendants!.append(newAttendant)
                    }
                }else{
                    let newAttendant = MeetingAttendant(givenName: givenName, familyName: familyName, email: email)
                    attendants = [MeetingAttendant]()
                    attendants!.append(newAttendant)
                }
                
                attendantTableView.reloadData()
            }else{
                let alert = UIAlertController(title: "Contact Not Imported", message: "\(givenName ?? "") \(familyName ?? "") \(email ?? "") has not been added because the contact was missing either their first name, last name, or email.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(confirmAction)
                picker.dismiss(animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func deleteAttendant(indexPath: IndexPath) {
        let row = indexPath.row
        
        if (row < attendants!.count) {
            let attendant = attendants![row]
            attendants!.remove(at: row)
            
            let parentController: MeetingTableViewController = self.parent as! MeetingTableViewController
            if let meeting = parentController.meeting {
                var targetAttendant: Attendant?
                if let storedAttendants = meeting.attendants{
                    for i in storedAttendants {
                        let current = i as! Attendant
                        if current.email == attendant.email {
                            targetAttendant = current
                        }
                    }
                }
                if let targetAttendant = targetAttendant{
                    attendantsToBeDeleted.append(targetAttendant)
                }
            }
            
            attendantTableView.deleteRows(at: [indexPath], with: .fade)
            attendantTableView.reloadData()
        }
    }
    
    func confirmDelete(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Participant", message: "Are you sure you want to delete this participant?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action) in
            self.deleteAttendant(indexPath: indexPath)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) in
            self.attendantTableView.reloadRows(at: [indexPath], with: .right)
        })
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let attendants = attendants{
            return attendants.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendantCell", for: indexPath)
        
        let givenName = attendants?[indexPath.row].givenName
        let familyName = attendants?[indexPath.row].familyName
        let email = attendants?[indexPath.row].email
        let titleString: String?
        
        if let givenName = givenName, let familyName = familyName {
            titleString = givenName + " " + familyName
            cell.textLabel?.text = titleString
        }
        if let email = email {
            cell.detailTextLabel?.text = email
        }
        
        
        
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDelete(indexPath: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

}
