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
    
    let game: GameType
    var buttons: [FactButton] = []
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let array = try PlistConverter.arrayFromFile(resource: "Facts", ofType: "plist")
            let facts = try InventoryUnarchiver.factsFromArray(array: array)
            self.game = Game(facts: facts, rounds: 3, timePerRound: 30, factsPerRound: 4)
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
        let round = game.selectNextRound() as! Round
        for i in 0..<round.facts.count {
            let factButton = FactButton(fact: round.facts[i], index: i, maxIndex: round.facts.count, target: self, action: #selector(buttonPressed(sender:)), view: self.view)
            buttons.append(factButton)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonPressed(sender: UIButton) {
        if let title = sender.currentTitle {
            print("Pressed button #\(sender.tag)")
            print("Title: \(title)")
        } else {
            if sender.tag > 0 {
                print("Pressed UP arrow of fact #\(sender.tag)")
            } else {
                print("Pressed DOWN arrow of fact #\(sender.tag)")
            }
        }
    }
}

