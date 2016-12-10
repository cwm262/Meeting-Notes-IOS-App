//
//  AgendaViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/13/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit
import CoreData

protocol AgendaSharing {
    func shareAgenda(agenda: Agenda?)
}

class CreateAgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var agenda: Agenda?
    var meetingTableController: AgendaSharing?
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?

    @IBOutlet weak var countdownTimer: UIDatePicker!
    @IBOutlet weak var taskTextView: UITextView!
    
    @IBOutlet weak var titleTableView: UITableView!
    @IBOutlet weak var taskView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskView.layer.borderWidth = 1
        taskView.layer.borderColor = UIColor(ciColor: CIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)).cgColor
        
        taskTextView.text = "Task"
        taskTextView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateAgendaViewController.addAgenda))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAgenda(){
        let titleCell = titleTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CreateAgendaTitleTableViewCell
        
        let context = DatabaseController.getContext()
        let desc = NSEntityDescription.entity(forEntityName: "Agenda", in: context)
        agenda = Agenda(entity: desc!, insertInto: context)
        agenda?.setValue(titleCell.titleField.text, forKey: "title")
        if taskTextView.text == "Task" {
            agenda?.setValue("", forKey: "task")
        } else {
            agenda?.setValue(taskTextView.text, forKey: "task")
        }
        let duration = countdownTimer?.countDownDuration
        agenda?.setValue(duration, forKey: "duration")
        if let meeting = meeting, let agenda = agenda {
            meeting.addToAgendas(agenda)
            DatabaseController.saveContext()
            self.meetingTableController?.shareAgenda(agenda: nil)
        }else{
            self.meetingTableController?.shareAgenda(agenda: agenda)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if tableView == self.titleTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! CreateAgendaTitleTableViewCell
            
        }
        
        return cell
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != UIColor.black {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let strArr = Array(textView.text.characters)
        var allSpaces = true
 
        for letter in strArr {
            if letter != " " {
                allSpaces = false
            }
        }
        
        if strArr.count == 0 || allSpaces {
            textView.text = "Task"
            textView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
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
