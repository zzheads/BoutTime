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
    var link: String { get }
    
    func getTitle() -> String
}

protocol Swapable {
    mutating func up(index: Int)
    mutating func down(index: Int)
}

protocol RoundType {
    init(facts: [FactType])
    func isSet() -> Bool
    func showAndGetButtons(target: Any?, action: Selector, view: UIView) -> [FactButtonType]
    func updateEventButtons(buttons: [FactButtonType])
}

protocol GameType {
    var facts: [FactType] { get }
    var rounds: Int { get }
    var timePerRound: Int { get }
    var correctAnswers: Int { get set }
    var roundsDone: Int { get set }
    var factsPerRound: Int { get }
    
    init(facts: [FactType], rounds: Int, timePerRound: Int, factsPerRound: Int)
    func selectNextRound() -> Round
    func isFinished() -> Bool
}

struct Fact: FactType {
    let event: String
    let year: Int
    let link: String
    
    func getTitle() -> String {
        var title = self.event
        if title.characters.count > 100 { // max length 100 chars
            let startIndex = title.index(title.startIndex, offsetBy: 100)
            title = title.substring(to: startIndex)
        }
        return title
    }
}

class Round: RoundType, Swapable {
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
            if facts[i].year > facts[i-1].year {
                isSet = false
            }
        }
        return isSet
    }
    
    func showAndGetButtons(target: Any?, action: Selector, view: UIView) -> [FactButtonType] {
        var buttons: [FactButtonType] = []
        for i in 0..<self.facts.count {
            let fact = self.facts[i]
            let factButton = FactButton(fact: fact, index: i, maxIndex: self.facts.count, target: target, action: action, view: view)
            buttons.append(factButton)
        }
        return buttons
    }
    
    func updateEventButtons(buttons: [FactButtonType]) {
        for i in 0..<self.facts.count {
            let fact = self.facts[i]
            let button = buttons[i]
            button.updateEventButton(fact: fact)
        }
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
    func selectNextRound() -> Round {
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

enum FactError: Error {
    case OutOfRange
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
            if let itemDict = element as? [String: AnyObject], let event = itemDict["event"] as? String, let year = itemDict["year"] as? Int, let link = itemDict["link"] as? String {
                let fact = Fact(event: event, year: year, link: link)
                facts.append(fact)
            }
        }
        return facts
    }
}












