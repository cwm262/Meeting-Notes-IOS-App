//
//  NoteViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 10/31/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var startTimeBtn: UIButton!
    @IBOutlet weak var endTimeBtn: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting cell detail with current date as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy    h:mm a"
        let date = Date(timeIntervalSinceNow: 0)
        let dateString = dateFormatter.string(from: date)
        startTimeBtn.setTitle(dateString, for: .normal)
        
        let endDate = Date(timeIntervalSinceNow: 3600)
        let endDateString = dateFormatter.string(from: endDate)
        endTimeBtn.setTitle(endDateString, for: .normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startTimeClicked(_ sender: Any) {
        
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
