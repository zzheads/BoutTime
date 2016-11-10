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
    @IBOutlet weak var nextRoundFailImageView: UIImageView!
    @IBOutlet weak var nextRoundSuccessImageView: UIImageView!
    @IBOutlet weak var webViewBar: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webBarCloseButton: UIButton!
    
    let game: GameType
    var buttons: [FactButtonType] = []
    var currentRound: Round
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let array = try PlistConverter.arrayFromFile(resource: "Facts", ofType: "plist")
            let facts = try InventoryUnarchiver.factsFromArray(array: array)
            self.game = Game(facts: facts, rounds: 3, timePerRound: 30, factsPerRound: 4)
        } catch let error {
            fatalError("\(error)")
        }
        self.currentRound = self.game.selectNextRound()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
        hideNextRoundImage()
        hideWeb()
        self.becomeFirstResponder()
        currentRound = game.selectNextRound()
        buttons = currentRound.showAndGetButtons(target: self, action: #selector(buttonPressed(sender:)), view: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Listeners
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("Device was shaken!")
        toggleNextRoundImage(success: self.currentRound.isSet())
    }
    
    func buttonPressed(sender: UIButton) {
        if let title = sender.currentTitle {
            let index = sender.tag
            let link = self.currentRound.facts[index].link
            print("Pressed button #\(sender.tag)")
            print("Title: \(title), Link: \(link)")
            hideButtons()
            showWeb(link: link)
        } else {
            if sender.tag > 0 {
                print("Pressed UP arrow of fact #\(sender.tag)")
                self.currentRound.up(index: sender.tag)
                self.currentRound.updateEventButtons(buttons: self.buttons)
            } else {
                print("Pressed DOWN arrow of fact #\(sender.tag)")
                self.currentRound.down(index: -sender.tag)
                self.currentRound.updateEventButtons(buttons: self.buttons)
            }
        }
    }
    
    @IBAction func closeWeb() {
        hideWeb()
        showButtons()
    }
    
    // Helper methods
    
    func showNextRoundImage(success: Bool) {
        if success {
            nextRoundSuccessImageView.isHidden = false
        } else {
            nextRoundFailImageView.isHidden = false
        }
    }
    
    func hideNextRoundImage() {
        nextRoundFailImageView.isHidden = true
        nextRoundSuccessImageView.isHidden = true
    }
    
    func toggleNextRoundImage(success: Bool) {
        if (nextRoundFailImageView.isHidden && nextRoundSuccessImageView.isHidden) {
            showNextRoundImage(success: success)
        } else {
            hideNextRoundImage()
        }
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
    
}

