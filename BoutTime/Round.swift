//
//  Round.swift
//  BoutTime
//
//  Created by Alexey Papin on 12.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import GameKit

protocol Swapable {
    mutating func up(index: Int)
    mutating func down(index: Int)
}

protocol RoundType {
    var facts: [FactType] { get set }
    
    init(facts: [FactType])
    func isSet() -> Bool
    func showAndGetButtons(target: Any?, action: Selector, view: UIView) -> [FactButtonType]
    func updateEventButtons(buttons: [FactButtonType])
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

// Errors

enum RoundError: Error {
    case InitializationError
}
