//
//  Event.swift
//  BoutTime
//
//  Created by Alexey Papin on 09.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import GameKit

protocol FactType {
    var event: String { get }
    var year: Int { get }
}

protocol RoundType {
    init(facts: [FactType])
    func isSet() -> Bool
    mutating func up(index: Int)
    mutating func down(index: Int)
    func getButton(forIndex index: Int) -> FactButton
}

protocol GameType {
    var facts: [FactType] { get }
    var rounds: Int { get }
    var timePerRound: Int { get }
    var correctAnswers: Int { get set }
    var roundsDone: Int { get set }
    var factsPerRound: Int { get }
    
    init(facts: [FactType], rounds: Int, timePerRound: Int, factsPerRound: Int)
    func selectNextRound() -> RoundType
    func isFinished() -> Bool
}

struct Fact: FactType {
    let event: String
    let year: Int
}

class Round: RoundType {
    var facts: [FactType]
    
    required init(facts: [FactType]) {
        self.facts = facts
    }
    
    func up(index: Int) {
        if index > 0 {
            swap(&facts[index], &facts[index-1])
        }
    }
    
    func down(index: Int) {
        if index < facts.count-1 {
            swap(&facts[index], &facts[index+1])
        }
    }
    
    // verify is all facts setted right due their date
    func isSet() -> Bool {
        var isSet = true
        for i in 1..<facts.count {
            if facts[i].year < facts[i-1].year {
                isSet = false
            }
        }
        return isSet
    }
    
    @objc func buttonPressed(sender: AnyObject) {
        print(sender.description)
    }
    
    func getButton(forIndex index: Int) -> FactButton {
        var x = 20
        let height = (Int(UIScreen.main.bounds.height) - 100 - 20 * self.facts.count) / self.facts.count
        let y = 20 + (height + 20) * index
        var width = Int(UIScreen.main.bounds.width) - 80
        let titleColor = UIColor(red: 8/255.0, green: 43/255.0, blue: 62/255.0, alpha: 1.0)
        let backgroundColor = UIColor.white
        
        var title = self.facts[index].event
        if title.characters.count > 100 {
            let startIndex = title.index(title.startIndex, offsetBy: 100)
            title = title.substring(to: startIndex)
        }
        
        let eventButton = UIButton(type: .system)
        eventButton.setTitle(title, for: .normal)
        eventButton.frame = CGRect(x: x, y: y, width: width, height: height)
        eventButton.setTitleColor(titleColor, for: .normal)
        eventButton.backgroundColor = backgroundColor
        eventButton.isHidden = false
        eventButton.layer.cornerRadius = 4
        eventButton.layer.masksToBounds = true
        eventButton.titleEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        eventButton.titleLabel?.numberOfLines = 0
        eventButton.titleLabel?.lineBreakMode = .byWordWrapping
        eventButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
        
        var upButton: UIButton? = nil
        var downButton: UIButton? = nil
        x += width - 4
        width = 40
        let halfHeight = height / 2
        
        switch index {
        case 0:
            downButton = UIButton(type: .system)
            downButton?.frame = CGRect(x: x, y: y, width: width, height: height)
            downButton?.setBackgroundImage(SwapButtons.down_full.icon(), for: .normal)
            downButton?.isHidden = false
            downButton?.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            break
        case 1..<self.facts.count - 1:
            upButton = UIButton(type: .system)
            upButton?.frame = CGRect(x: x, y: y, width: width, height: halfHeight)
            upButton?.setBackgroundImage(SwapButtons.up_half.icon(), for: .normal)
            upButton?.isHidden = false
            upButton?.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            
            downButton = UIButton(type: .system)
            downButton?.frame = CGRect(x: x, y: y + halfHeight, width: width, height: height - halfHeight)
            downButton?.setBackgroundImage(SwapButtons.down_half.icon(), for: .normal)
            downButton?.isHidden = false
            downButton?.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            break
        case self.facts.count - 1:
            upButton = UIButton(type: .system)
            upButton?.frame = CGRect(x: x, y: y, width: width, height: height)
            upButton?.setBackgroundImage(SwapButtons.up_full.icon(), for: .normal)
            upButton?.isHidden = false
            downButton?.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
            break
        default:
            break
        }
        return FactButton(eventButton: eventButton, upButton: upButton, downButton: downButton)
    }
}

class Game: GameType {
    let facts: [FactType]
    let rounds: Int
    let timePerRound: Int
    var correctAnswers: Int
    var roundsDone: Int
    let factsPerRound: Int
    
    required init(facts: [FactType], rounds: Int, timePerRound: Int, factsPerRound: Int) {
        self.facts = facts
        self.rounds = rounds
        self.timePerRound = timePerRound
        self.correctAnswers = 0
        self.roundsDone = 0
        self.factsPerRound = factsPerRound
    }
    
    // select factsPerRound (4) random facts from facts array, avoid repeats
    func selectNextRound() -> RoundType {
        var choosenFacts: [FactType] = []
        var randomIndex: Int
        var indexesUsed: [Int] = [] // store here already choosen fact indexes
        for _ in 0..<self.factsPerRound {
            repeat {
                randomIndex = Int(GKRandomSource.sharedRandom().nextInt(upperBound: self.facts.count))
            } while indexesUsed.contains(randomIndex)
            indexesUsed.append(randomIndex)
            choosenFacts.append(self.facts[randomIndex])
        }
        
        return Round(facts: choosenFacts)
    }
    
    func isFinished() -> Bool {
        if self.roundsDone >= self.rounds {
            return true
        }
        return false
    }
}

// Errors types 

enum InventoryError: Error {
    case InvalidResource
    case ConversionError
    case InvalidKey
}

// Helper classes

class PlistConverter {
    class func arrayFromFile(resource: String, ofType type: String) throws -> [AnyObject] {
        guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
            throw InventoryError.InvalidResource
        }
        guard let array = NSArray(contentsOfFile: path) else {
            throw InventoryError.ConversionError
        }
        return array as [AnyObject]
    }
}

class InventoryUnarchiver {
    class func factsFromArray(array: [AnyObject]) throws -> [FactType] {
        var facts: [FactType] = []
        for element in array {
            if let itemDict = element as? [String: AnyObject], let event = itemDict["event"] as? String, let year = itemDict["year"] as? Int {
                let fact = Fact(event: event, year: year)
                facts.append(fact)
            }
        }
        return facts
    }
}












