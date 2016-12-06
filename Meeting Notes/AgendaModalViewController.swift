//
//  AgendaModalViewController.swift
//  Meeting Notes
//
//  Created by Cody McCarson on 11/29/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class AgendaModalViewController: UIViewController, UITextViewDelegate {
    
    var agenda: Agenda?
    var meeting: Meeting?
    var showMeetingController: ShowMeetingViewController?
    var timer: Int = 0
    var agendaTimer = Timer()
    var runningTimer = true

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var pauseResumeBtn: UIBarButtonItem!

    
    @IBAction func dismissEditingNotes(_ sender: UITapGestureRecognizer) {
        notesTextView.resignFirstResponder()
    }
//    @IBAction func modalClosed(_ sender: Any) {
//        if let showMeetingController = showMeetingController {
//            showMeetingController.meetingBegin = false
//            let path = IndexPath(row: showMeetingController.currentAgenda, section: 0)
//            showMeetingController.agendaTableView.cellForRow(at: path)?.isSelected = false
//        }
//        meeting!.notes = notesTextView.text
//        DatabaseController.saveContext()
//        agendaTimer.invalidate()
//        self.dismiss(animated: true, completion: {})
//    }
    override func viewDidLoad() {
        styleModal()
        agendaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        if let agenda = agenda {
            timerLabel.text = timeFormatted(totalSeconds: Int(agenda.duration))
            title = agenda.title
            taskTextView.text = agenda.task
            taskTextView.isEditable = false
            taskTextView.isSelectable = false
        }
        if let meeting = meeting {
            notesTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            notesTextView.text = meeting.notes
        }
        let range: NSRange = NSMakeRange(notesTextView.text.characters.count - 1, 0)
        notesTextView.scrollRangeToVisible(range)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func styleModal(){
        notesTextView.text = "Add Notes Here"
        notesTextView.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        //modalView.layer.cornerRadius = 13.0
        //modalView.clipsToBounds = true
        notesTextView.layer.cornerRadius = 10.0
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
    }
    
    func countdown() {
        if timer > 0 {
            timer -= 1
            let timeString: String = timeFormatted(totalSeconds: timer)
            timerLabel.text = timeString
        } else {
            agendaTimer.invalidate()
            
            var path = IndexPath(row: (showMeetingController?.currentAgenda)!, section: 0)
            showMeetingController?.agendaTableView.cellForRow(at: path)?.isSelected = false
            
            if (showMeetingController?.currentAgenda)! < (showMeetingController?.meetingAgendas?.count)! - 1{
            
                showMeetingController?.currentAgenda += 1

                path = IndexPath(row: (showMeetingController?.currentAgenda)!, section: 0)
                //showMeetingController?.goToNextModal(path: path)
                
            } else {
                showMeetingController?.meetingBegin = false
            }
            meeting!.notes = notesTextView.text
            DatabaseController.saveContext()
            self.dismiss(animated: true, completion: {})
        }
        
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    //MARK: Functions that Deal with TextViews and TextFields
    func textViewDidBeginEditing(_ textView: UITextView) {
        if notesTextView.text == "Add Notes Here" {
            notesTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            notesTextView.text = ""
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if notesTextView.text.characters.count == 0 {
            notesTextView.text = "Add Notes Here"
            notesTextView.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
    }
    @IBAction func goToNextAgenda(_ sender: Any) {
        var path = IndexPath(row: (showMeetingController?.currentAgenda)!, section: 0)
        showMeetingController?.agendaTableView.cellForRow(at: path)?.isSelected = false
        
        if (showMeetingController?.currentAgenda)! < (showMeetingController?.meetingAgendas?.count)! - 1{
            
            showMeetingController?.currentAgenda += 1
            
            path = IndexPath(row: (showMeetingController?.currentAgenda)!, section: 0)
            //showMeetingController?.goToNextModal(path: path)
            
        }
        
    }
    @IBAction func changeTimeState(_ sender: Any) {
        if runningTimer {
            agendaTimer.invalidate()
            runningTimer = false
            pauseResumeBtn.title = "Resume"
            //pauseResumeBtn.setTitle("Resume", for: .normal)
            timerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }else{
            agendaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
            runningTimer = true
            pauseResumeBtn.title = "Pause"
            //pauseResumeBtn.setTitle("Pause", for: .normal)
            timerLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
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
