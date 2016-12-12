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
    var noAttendants: Bool = false
    var editingAttendants: Bool = false
    
    @IBOutlet weak var attendantTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendantTableView.setEditing(editingAttendants, animated: true)
        
        if editingAttendants {
            let addButton = UIBarButtonSystemItem.add
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: addButton, target: self, action: #selector(self.importParticipant))
        }
        
        if let meeting = meeting {
            if meeting.attendants?.count == 0 || meeting.attendants == nil {
                noAttendants = true
                importParticipant()
            }
        }
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
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        if noAttendants {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts{
            let givenName: String? = contact.givenName
            let familyName: String? = contact.familyName
            let email: String? = contact.emailAddresses.first?.value as String?
            
            if let givenName = givenName, let familyName = familyName, let email = email{
                let context = DatabaseController.getContext()
                let desc = NSEntityDescription.entity(forEntityName: "Attendant", in: context)
                let newAttendant = Attendant(entity: desc!, insertInto: context)
                newAttendant.setValue(givenName, forKey: "givenName")
                newAttendant.setValue(familyName, forKey: "familyName")
                newAttendant.setValue(email, forKey: "email")
                self.meeting?.addToAttendants(newAttendant)
                print(self.meeting)
            }else{
                let alert = UIAlertController(title: "Contact Not Imported", message: "\(givenName ?? "") \(familyName ?? "") \(email ?? "") has not been added because the contact was missing either their first name, last name, or email.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(confirmAction)
                picker.dismiss(animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }
        }
        attendantTableView.reloadData()
    }
    
    func deleteAttendant(indexPath: IndexPath) {
        let row = indexPath.row
        
        if let meeting = meeting, let attendants = meeting.attendants {
            if row < attendants.count {
                let attendant = attendants[row] as! Attendant
                meeting.removeFromAttendants(attendant)
            }
        }
            
        attendantTableView.deleteRows(at: [indexPath], with: .fade)
        attendantTableView.reloadData()
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
        if let meeting = meeting, let attendants = meeting.attendants{
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
        
        if let meeting = meeting, let attendants = meeting.attendants {
            let attendant = attendants[indexPath.row] as! Attendant
            let givenName = attendant.givenName
            let familyName = attendant.familyName
            let email = attendant.email
            let titleString: String?
            
            if let givenName = givenName, let familyName = familyName {
                titleString = givenName + " " + familyName
                cell.textLabel?.text = titleString
            }
            if let email = email {
                cell.detailTextLabel?.text = email
            }
            
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
