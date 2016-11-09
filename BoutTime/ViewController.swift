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
            let factButton = round.getButton(forIndex: i)
            self.view.addSubview(factButton.eventButton)
            
            if let upButton = factButton.upButton {
                self.view.addSubview(upButton)
            }
            
            if let downButton = factButton.downButton {
                self.view.addSubview(downButton)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

