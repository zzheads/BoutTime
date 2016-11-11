//
//  Event.swift
//  BoutTime
//
//  Created by Alexey Papin on 09.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import GameKit


protocol GameType {
    var facts: [FactType] { get }
    var rounds: Int { get }
    var timePerRound: Int { get }
    var roundsDone: Int { get set }
    var factsPerRound: Int { get }
    var completedRounds: Int { get set }
    var currentRound: RoundType? { get set }
    
    init(facts: [FactType], rounds: Int, timePerRound: Int, factsPerRound: Int)
    func getNextRound() -> Round
    func isFinished() -> Bool
    func getCurrentRound() -> RoundType?
}

class Game: GameType {
    let facts: [FactType]
    let rounds: Int
    let timePerRound: Int
    var roundsDone: Int
    let factsPerRound: Int
    var completedRounds: Int
    var currentRound: RoundType?
    
    required init(facts: [FactType], rounds: Int, timePerRound: Int, factsPerRound: Int) {
        self.facts = facts
        self.rounds = rounds
        self.timePerRound = timePerRound
        self.roundsDone = 0
        self.factsPerRound = factsPerRound
        self.completedRounds = 0
        self.currentRound = nil
    }
    
    // select factsPerRound (4) random facts from facts array, avoid repeats
    func getNextRound() -> Round {
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
    
    func getCurrentRound() -> RoundType? {
        return self.currentRound
    }
    
    func finishRound() {
        self.roundsDone += 1
        if let currentRound = self.currentRound {
            if currentRound.isSet() {
                completedRounds += 1
            }
        }
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












