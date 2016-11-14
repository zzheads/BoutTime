//
//  ViewController.swift
//  BoutTime
//
//  Created by Alexey Papin on 09.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var webViewBar: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webBarCloseButton: UIButton!
    @IBOutlet weak var nextRoundSuccessButton: UIButton!
    @IBOutlet weak var nextRoundFailButton: UIButton!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var shakeLabel: UILabel!
    
    let game: Game
    let TIME_PER_ROUND = 60                 // in seconds
    let ROUNDS_IN_GAME = 6
    var buttons: [FactButton] = []
    var webEnabled: Bool = false            // enable web only when successfully ended round between rounds
    var wasSelectedButtonIndex: Int = 0
    var currentRound: Round
    var timer: Timer?
    var timeElapsed: Int = 0
    let selectorToTimerUpdateFunc: Selector = #selector(updateTimer)
    var isShakeable: Bool = false {
        didSet {
            self.shakeLabel.isHidden = !self.isShakeable
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let array = try PlistConverter.arrayFromFile(resource: "Facts", ofType: "plist")
            let facts = try InventoryUnarchiver.factsFromArray(array: array)
            self.game = Game(facts: facts, rounds: self.ROUNDS_IN_GAME, factsPerRound: 4)
            try self.currentRound = self.game.getNextRound()
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
        hideResults()
        hideNextRoundButton()
        hideWeb()
    
        self.becomeFirstResponder()
        self.buttons = self.currentRound.showAndGetButtons(target: self, action: #selector(buttonPressed(sender:)), view: self.view)
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Listeners
    
    // Shake phone listener
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        // print("Device was shaken!")
        if self.isShakeable {
            stopTimer()
            let roundCompleted = self.currentRound.isSet()
            showNextRoundButton(success: roundCompleted)
            self.webEnabled = true
        }
    }
    
    func updateTimer() {
        self.timeElapsed += 1
        self.timeLabel.text = String(format: "0:%02d", self.timeElapsed)

        if self.timeElapsed == self.TIME_PER_ROUND {
            stopTimer()
            let roundCompleted = self.currentRound.isSet()
            showNextRoundButton(success: roundCompleted)
            if roundCompleted {
                self.webEnabled = true
            }
        }
    }
    
    func buttonPressed(sender: UIButton) {
        if sender.currentTitle != nil {                                 // sender is eventButton when title is not nil, else it's up or down button
            let index = sender.tag
            let link = self.currentRound.facts[index].link
            // print("Pressed event button #\(sender.tag)")
            if (webEnabled) {
                hideButtons()
                showWeb(link: link)
            }
        } else {
            self.buttons[self.wasSelectedButtonIndex].unSelect()        // unselect previously selected button
            if sender.tag > 0 {
                // print("Pressed UP arrow of fact #\(sender.tag)")
                self.buttons[sender.tag].select()                       // select tapped button
                self.currentRound.up(index: sender.tag)
                self.currentRound.updateEventButtons(buttons: self.buttons)
                self.buttons[sender.tag].unSelect()                     // unselect tapped button
                self.buttons[sender.tag - 1].select()                   // select where tapped fact moved
                self.wasSelectedButtonIndex = sender.tag - 1            // store selected button index, same procedure down with down move:
            } else {
                // print("Pressed DOWN arrow of fact #\(sender.tag)")
                self.buttons[-sender.tag].select()
                self.currentRound.down(index: -sender.tag)
                self.currentRound.updateEventButtons(buttons: self.buttons)
                self.buttons[-sender.tag].unSelect()
                self.buttons[-sender.tag + 1].select()
                self.wasSelectedButtonIndex = -sender.tag + 1
            }
        }
    }
    
    // close web button on webBar pressed
    @IBAction func closeWeb() {
        hideWeb()
        showButtons()
    }
    
    @IBAction func nextRoundFailPressed() {
        finishRound()
    }
    
    @IBAction func nextRoundSuccessPressed() {
        finishRound()
    }
    
    @IBAction func playAgainButtonPressed() {
        hideResults()
        self.game.restart()
        do {
            try self.currentRound = self.game.getNextRound()
        } catch let error {
            fatalError("\(error)")
        }
        self.buttons = self.currentRound.showAndGetButtons(target: self, action: #selector(buttonPressed(sender:)), view: self.view)
        startTimer()
    }
    
    @IBAction func helpButtonPressed() {
        showAlert(title: "Sort historical facts from newest to oldest (top to bottom).\n So newer fact must be upper than older one.")
    }
    
    // Helper methods
    
    func showAlert(title: String, message: String? = nil, style: UIAlertControllerStyle = .alert ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: dismissAlert(sender:))
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func dismissAlert(sender: UIAlertAction) {
    }
    
    func startTimer() {
        self.isShakeable = true
        
        self.timeElapsed = 0
        self.timeLabel.text = "0:00"
        self.timeLabel.isHidden = false
        self.timer = Timer.init()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: self.selectorToTimerUpdateFunc, userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.isShakeable = false
        
        if let timer = self.timer {
            timer.invalidate()
        }
        self.timeLabel.isHidden = true
    }
    
    func finishRound() {
        hideNextRoundButton()
        removeButtonsFromView()
        self.buttons.removeAll()
        self.webEnabled = false
        // start next round
        do {
            try self.game.finishRound()
        } catch let error {
            fatalError("\(error)")
        }
        if !game.isFinished() {
            do {
                try self.currentRound = self.game.getNextRound()
            } catch let error {
                fatalError("\(error)")
            }
            self.buttons = self.currentRound.showAndGetButtons(target: self, action: #selector(buttonPressed(sender:)), view: self.view)
            startTimer()
        } else {
            // show results and play again button
            showResults()
        }
    }
    
    func hideResults() {
        resultsLabel.isHidden = true
        playAgainButton.isHidden = true
    }
    
    func showResults() {
        resultsLabel.text = "Rounds played: \(self.game.roundsDone)\nCompleted correctly: \(self.game.completedRounds)"
        resultsLabel.isHidden = false
        playAgainButton.isHidden = false
    }
    
    func showNextRoundButton(success: Bool) {
        timeLabel.isHidden = true
        if success {
            nextRoundSuccessButton.isHidden = false
        } else {
            nextRoundFailButton.isHidden = false
        }
    }
    
    func hideNextRoundButton() {
        timeLabel.isHidden = false
        nextRoundFailButton.isHidden = true
        nextRoundSuccessButton.isHidden = true
    }
        
    func showWeb(link: String) {
        webView.isHidden = false
        webViewBar.isHidden = false
        webBarCloseButton.isHidden = false
        if let url = URL(string: link) {
            webView.loadRequest(URLRequest(url: url))
        } else {
            print("Cant make url: \(link)")
        }
    }
    
    func hideWeb() {
        webViewBar.isHidden = true
        webView.isHidden = true
        webBarCloseButton.isHidden = true
    }
    
    func hideButtons() {
        for button in self.buttons {
            button.hide()
        }
    }
    
    func showButtons() {
        for button in self.buttons {
            button.show()
        }
    }
    
    func removeButtonsFromView() {
        for button in self.buttons {
            button.removeFromSuperview()
        }
    }
}

