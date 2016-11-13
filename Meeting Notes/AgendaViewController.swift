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
    func shareAgenda(agenda: Agenda)
}

class AgendaViewController: UIViewController {
    
    var agenda: Agenda?
    var delegate: AgendaSharing?

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var taskField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(AgendaViewController.addAgenda))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAgenda(){
        let context = DatabaseController.getContext()
        if agenda == nil {
            let desc = NSEntityDescription.entity(forEntityName: "Agenda", in: context)
            agenda = Agenda(entity: desc!, insertInto: context)
            agenda?.setValue(titleField.text, forKey: "title")
            agenda?.setValue(taskField.text, forKey: "task")
            self.delegate?.shareAgenda(agenda: agenda!)
        }
        
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
