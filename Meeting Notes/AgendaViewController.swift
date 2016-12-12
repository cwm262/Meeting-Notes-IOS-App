//
//  AgendaViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/14/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var meeting: Meeting?
    var myAgendaSet: NSMutableOrderedSet?

    @IBOutlet weak var agendaTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Agendas"
        
        agendaTableView.setEditing(true, animated: true)
        
        let addButton = UIBarButtonSystemItem.add
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: addButton, target: self, action: #selector(self.addAgenda))
        
        if let meeting = meeting {
            myAgendaSet = meeting.mutableOrderedSetValue(forKey: "agendas")
            if myAgendaSet?.count == 0 {
                addAgenda()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        agendaTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let myAgendaSet = myAgendaSet {
            return myAgendaSet.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "agendaCell", for: indexPath)
        
        let agenda = myAgendaSet?[indexPath.row] as! Agenda
        cell.textLabel?.text = agenda.title
        
        let duration = agenda.duration
        
        cell.detailTextLabel?.text = TimerController.calculate(duration: duration)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = myAgendaSet?[sourceIndexPath.row]
        myAgendaSet?.removeObject(at: sourceIndexPath.row)
        myAgendaSet?.insert(sourceRow!, at: destinationIndexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
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
    
    func addAgenda(){
        let createAgendaViewController = storyboard?.instantiateViewController(withIdentifier: "createAgendaViewController") as! CreateAgendaViewController
        createAgendaViewController.meeting = self.meeting
        createAgendaViewController.agendaViewController = self
        navigationController?.pushViewController(createAgendaViewController, animated: true)
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
        
        if (row < (myAgendaSet?.count)!) {
            
            myAgendaSet?.removeObject(at: row)
            
            agendaTableView.deleteRows(at: [indexPath], with: .fade)
            agendaTableView.reloadData()
        }
    }

}
