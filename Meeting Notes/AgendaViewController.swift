//
//  AgendaViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/14/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var agendas: [Agenda]?
    var agendasToBeDeleted: [Agenda]?
    var meeting: Meeting?

    @IBOutlet weak var agendaTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        agendaTableView.setEditing(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        agendaTableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let agendas = agendas {
            return agendas.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "agendaCell", for: indexPath)
        
        cell.textLabel?.text = agendas?[indexPath.row].title
        if let duration = agendas?[indexPath.row].duration {
            if duration == 60 {
                cell.detailTextLabel?.text = "1 min"
            }else if duration > 60 && duration < 3600 {
                let numMinutes = duration / 60
                cell.detailTextLabel?.text = "\(numMinutes) min"
            }else if duration > 3600 {
                let numHours = duration / 3600
                let numMinutes = (duration % 3600) / 60
                cell.detailTextLabel?.text = "\(numHours) hr \(numMinutes) min"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = agendas?[sourceIndexPath.row]
        let myAgendaSet = meeting?.mutableOrderedSetValue(forKey: "agendas")
        //myAgendaSet?.exchangeObject(at: sourceIndexPath.row, withObjectAt: destinationIndexPath.row)
        myAgendaSet?.removeObject(at: sourceIndexPath.row)
        myAgendaSet?.insert(sourceRow!, at: destinationIndexPath.row)
        agendas?.remove(at: sourceIndexPath.row)
        agendas?.insert(sourceRow!, at: destinationIndexPath.row)
        DatabaseController.saveContext()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDelete(indexPath: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func confirmDelete(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Agenda", message: "Are you sure you want to delete this agenda?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action) in
            self.deleteAgenda(indexPath: indexPath)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) in
            self.agendaTableView.reloadRows(at: [indexPath], with: .right)
        })
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAgenda(indexPath: IndexPath) {
        let row = indexPath.row
        
        if (row < agendas!.count) {
        
            if var agendasToBeDeleted = agendasToBeDeleted {
                agendasToBeDeleted.append(agendas![row])
            }else {
                agendasToBeDeleted = [Agenda]()
                agendasToBeDeleted!.append(agendas![row])
            }
            
            agendas!.remove(at: row)
            
            let parentController: MeetingTableViewController = self.parent as! MeetingTableViewController
        
            parentController.meetingAgendas = agendas
            parentController.agendasToBeDeleted = agendasToBeDeleted
            
            agendaTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
