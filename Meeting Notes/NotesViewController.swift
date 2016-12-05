//
//  NotesViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 12/4/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    var notes: String?
    var meeting: Meeting?

    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let notes = notes {
            notesTextView.text = notes
        }

        title = "Notes"
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if let meeting = meeting {
            meeting.notes = notesTextView?.text
            DatabaseController.saveContext()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
