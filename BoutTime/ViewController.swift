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
    
    let game: GameType
    var buttons: [FactButtonType] = []
    var webEnabled: Bool = false            // enable web only when successfully ended round between rounds
    var wasSelectedButtonIndex: Int = 0
    var currentRound: Round
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let array = try PlistConverter.arrayFromFile(resource: "Facts", ofType: "plist")
            let facts = try InventoryUnarchiver.factsFromArray(array: array)
            self.game = Game(facts: facts, rounds: 3, timePerRound: 30, factsPerRound: 4)
        } catch let error {
            fatalError("\(error)")
        }
        self.currentRound = self.game.getNextRound()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
        hideNextRoundButton()
        hideWeb()
    
        self.becomeFirstResponder()
        self.buttons = self.currentRound.showAndGetButtons(target: self, action: #selector(buttonPressed(sender:)), view: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Listeners
    
    // Shake phone listener
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        // print("Device was shaken!")
        let roundCompleted = self.currentRound.isSet()
        showNextRoundButton(success: roundCompleted)
    }
    
    func buttonPressed(sender: UIButton) {
        if sender.currentTitle != nil {                                 // sender is eventButton when title is not nil, else it's up or down button
            let index = sender.tag
            let link = self.currentRound.facts[index].link
            // print("Pressed button #\(sender.tag)")
            // print("Title: \(title), Link: \(link)")
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
        hideNextRoundButton()
    }
    
    @IBAction func nextRoundSuccessPressed() {
        hideNextRoundButton()
        removeButtonsFromView()
        self.buttons.removeAll()
        // start next round
    }
    
    // Helper methods
    
    func showNextRoundButton(success: Bool) {
        if success {
            nextRoundSuccessButton.isHidden = false
        } else {
            nextRoundFailButton.isHidden = false
        }
    }
    
    func hideNextRoundButton() {
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
            button.eventButton.isHidden = true
            if let downImage = button.downImage, let downButton = button.downButton {
                downImage.isHidden = true
                downButton.isHidden = true
            }
            if let upImage = button.upImage, let upButton = button.upButton {
                upImage.isHidden = true
                upButton.isHidden = true
            }
        }
    }
    
    func showButtons() {
        for button in self.buttons {
            button.eventButton.isHidden = false
            if let downImage = button.downImage, let downButton = button.downButton {
                downImage.isHidden = false
                downButton.isHidden = false
            }
            if let upImage = button.upImage, let upButton = button.upButton {
                upImage.isHidden = false
                upButton.isHidden = false
            }
        }
    }
    
    func removeButtonsFromView() {
        for button in self.buttons {
            button.eventButton.removeFromSuperview()
            if let upImage = button.upImage, let upButton = button.upButton {
                upImage.removeFromSuperview()
                upButton.removeFromSuperview()
            }
            if let downImage = button.downImage, let downButton = button.downButton {
                downImage.removeFromSuperview()
                downButton.removeFromSuperview()
            }
        }
    }
}

