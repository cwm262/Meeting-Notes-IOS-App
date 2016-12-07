//
//  MeetingsTblViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson, Ben Friedman on 11/3/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class MeetingsTblViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, MFMailComposeViewControllerDelegate {
    
    var meetings = [Meeting]()
    var filteredMeetings = [Meeting]()
    var startPredicate: NSPredicate?
    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentState: UISegmentedControl!
    
    @IBAction func segmentDidSwitch(_ sender: Any) {
        changeFilter()
        updateSearchResults(for: searchController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meetings"
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: false)
        meetings = getMeetings()
        tableView.reloadData()
        changeFilter()
        updateSearchResults(for: searchController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func getMeetings() -> [Meeting] {
        let fetchRequest: NSFetchRequest<Meeting> = Meeting.fetchRequest()
        
        if (segmentState.selectedSegmentIndex == 0) {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
            fetchRequest.predicate = startPredicate
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
            fetchRequest.predicate = startPredicate
        }
        
        do {
            let foundMeetings = try DatabaseController.getContext().fetch(fetchRequest)
            return foundMeetings
        } catch {
            print ("Error retrieving notes")
        }
        
        return [Meeting]()
    }
    
    func deleteMeeting(indexPath: IndexPath) {
        let row = indexPath.row
        
        if (row < filteredMeetings.count) {
            let meeting = filteredMeetings[row]
            filteredMeetings.remove(at: row)
            DatabaseController.getContext().delete(meeting)
            
            DatabaseController.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        changeFilter()
        updateSearchResults(for: searchController)
    }
    
    func editMeeting(indexPath: IndexPath) {
        let row = indexPath.row
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MeetingTableViewController") as? MeetingTableViewController
        nextViewController?.meeting = meetings[row]
        self.navigationController?.pushViewController(nextViewController!, animated: true)
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
    
    //MARK: Configure table cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath)
        let startTimeString = filteredMeetings[indexPath.row].startTime as? Date
        
        cell.textLabel?.text = filteredMeetings[indexPath.row].title //Set cell title
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: startTimeString!, dateStyle: .medium, timeStyle: .short)
        
        return cell
    }
    
    //MARK: Show edit and delete buttons on table row
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action , indexPath) -> Void in
            self.confirmDelete(indexPath: indexPath)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit") { (action , indexPath) -> Void in
            self.editMeeting(indexPath: indexPath)
        }
        editAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Share") { (action , indexPath) -> Void in
            self.shareMeeting(indexPath: indexPath)
        }
        shareAction.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        return [deleteAction, editAction, shareAction]
    }
    
    func changeFilter() {
        let currDate = NSDate() as Date
        
        if (segmentState.selectedSegmentIndex == 0) {
            self.startPredicate = NSPredicate(format: "startTime > %@", currDate as NSDate)
            self.meetings = self.getMeetings()
            self.tableView.reloadData()
        }
        else {
            self.startPredicate = NSPredicate(format: "startTime < %@", currDate as NSDate)
            self.meetings = self.getMeetings()
            self.tableView.reloadData()
        }
    }
    
    func filter(_ searchText: String) -> [Meeting] {
        var filteredMeeting = [Meeting]()
        
        if searchText.isEmpty {
            filteredMeeting = meetings
        } else {
            for meeting in meetings {
                if meeting.title?.range(of: searchText, options: .caseInsensitive) != nil {
                    filteredMeeting.append(meeting)
                } else if meeting.description.range(of: searchText, options: .caseInsensitive) != nil {
                    filteredMeeting.append(meeting)
                }
            }
        }
        return filteredMeeting
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredMeetings = filter(searchText)
            tableView.reloadData()
        }
    }
    
    func shareMeeting(indexPath: IndexPath){
        let title = filteredMeetings[indexPath.row].title!
        let location = filteredMeetings[indexPath.row].location!
        let startTime = filteredMeetings[indexPath.row].startTime!
        let start = DateFormatter.localizedString(from: startTime as Date, dateStyle: .medium, timeStyle: .short)
        let description = filteredMeetings[indexPath.row].desc!
        var attendees = [String]()
        
        if MFMailComposeViewController.canSendMail() {
            let compose = MFMailComposeViewController()
            compose.mailComposeDelegate = self
            
            if let attendants = filteredMeetings[indexPath.row].attendants {
                for attendant in attendants {
                    let currentAttendant = attendant as? Attendant
                    attendees.append((currentAttendant?.email)!)
                    
                }
            }
            
            compose.setToRecipients(attendees)
            compose.setSubject(filteredMeetings[indexPath.row].title!)
            compose.setMessageBody("<h2>\(title) </h2> <br /> Location/Time: \(location) <br />Start Time: \(start)<br /> Description: \(description)" , isHTML: true)
            
            // Present the view controller modally.
            self.present(compose, animated: true, completion: nil)
            
            
            
            
        }
            
        else {
            let alert = UIAlertController(title: "Cannot send mail", message: "Cannot Send Mail", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "show"),
            let destination = segue.destination as? ShowMeetingViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.meeting = filteredMeetings[indexPath.row]
        }
    }
}
