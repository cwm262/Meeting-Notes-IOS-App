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
    func shareAgenda()
}

class CreateAgendaViewController: UIViewController {
    
    var agenda: Agenda?
    var meetingTableController: AgendaSharing?
    var meeting: Meeting?
    var meetingAgendas: [Agenda]?

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var taskField: UITextView!
    @IBOutlet weak var countdownTimer: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateAgendaViewController.addAgenda))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAgenda(){
        let context = DatabaseController.getContext()
        let desc = NSEntityDescription.entity(forEntityName: "Agenda", in: context)
        agenda = Agenda(entity: desc!, insertInto: context)
        agenda?.setValue(titleField.text, forKey: "title")
        agenda?.setValue(taskField.text, forKey: "task")
        let duration = countdownTimer?.countDownDuration
        agenda?.setValue(duration, forKey: "duration")
        if let meeting = meeting, let agenda = agenda {
            meeting.addToAgendas(agenda)
        }
        DatabaseController.saveContext()
        self.meetingTableController?.shareAgenda()
        
        _ = navigationController?.popViewController(animated: true)
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
