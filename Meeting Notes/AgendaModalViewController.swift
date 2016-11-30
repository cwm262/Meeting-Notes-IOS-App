//
//  AgendaModalViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/29/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class AgendaModalViewController: UIViewController {
    
    var agenda: Agenda?
    var meeting: Meeting?
    var showMeetingController: ShowMeetingViewController?
    var timer: Int = 0
    //var currentAgenda = 0
    var agendaTimer = Timer()

    @IBOutlet weak var timerLabel: UILabel!
    
    @IBAction func modalClosed(_ sender: Any) {
        if let showMeetingController = showMeetingController {
            showMeetingController.meetingBegin = false
            let path = IndexPath(row: showMeetingController.currentAgenda, section: 0)
            showMeetingController.agendaTableView.cellForRow(at: path)?.isSelected = false
        }
        self.dismiss(animated: true, completion: {})
    }
    override func viewDidLoad() {
        agendaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func countdown() {
        if timer > 0 {
            timer -= 1
            let timeString: String = timeFormatted(totalSeconds: timer)
            timerLabel.text = timeString
        } else {
            agendaTimer.invalidate()
            
            let path = IndexPath(row: (showMeetingController?.currentAgenda)!, section: 0)
            showMeetingController?.agendaTableView.cellForRow(at: path)?.isSelected = false
            
            if (showMeetingController?.currentAgenda)! < (showMeetingController?.meetingAgendas?.count)! - 1{
                
                showMeetingController?.currentAgenda += 1
                
                showMeetingController?.checkForTableViewTransition = true
                
//                path = IndexPath(row: (showMeetingController?.currentAgenda)!, section: 0)
//                showMeetingController?.tableView((showMeetingController?.agendaTableView)!, didSelectRowAt: path)
                
            } else {
                showMeetingController?.meetingBegin = false
            }
            
            self.dismiss(animated: true, completion: {})
        }
        
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
