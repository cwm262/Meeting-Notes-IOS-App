//
//  AttendantViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/11/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData

class AttendantViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var attendants: [MeetingAttendant]?
    var attendantsToBeDeleted: [Attendant] = [Attendant]()
    
    @IBOutlet weak var attendantTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            
            parentController.meetingAttendants = attendants
            parentController.attendantsToBeDeleted = attendantsToBeDeleted
            
            attendantTableView.deleteRows(at: [indexPath], with: .fade)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendantCell", for: indexPath)
        
        cell.textLabel?.text = attendants?[indexPath.row].givenName
        
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
