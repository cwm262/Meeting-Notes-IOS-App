//
//  MeetingsTblViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson, Ben Friedman on 11/3/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData

class MeetingsTblViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var meetings = [Meeting]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meetings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: false)
        meetings = getMeetings()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    func getMeetings() -> [Meeting] {
        let fetchRequest = NSFetchRequest<Meeting>(entityName: "Meeting")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        do {
            let foundTasks = try getContext().fetch(fetchRequest)
            return foundTasks
        } catch {
            print ("Error retrieving notes")
        }
        
        return [Meeting]()
    }
    
    func deleteMeeting(indexPath: IndexPath) {
        let row = indexPath.row
        
        if (row < meetings.count) {
            let meeting = meetings[row]
            meetings.remove(at: row)
            getContext().delete(meeting)
            
            do {
                try getContext().save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func confirmDelete(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Meeting", message: "Are you sure you want to delete the meeting?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action) in
            self.deleteMeeting(indexPath: indexPath)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) in
            self.tableView.reloadRows(at: [indexPath], with: .right)
        })
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath)
        
        cell.textLabel?.text = meetings[indexPath.row].title //Set cell title
        let startTimeString = meetings[indexPath.row].startTime as! Date
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: startTimeString, dateStyle: .medium, timeStyle: .short)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "show"),
            let destination = segue.destination as? MeetingTableViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.meeting = meetings[indexPath.row]
            
        }
    }
}
