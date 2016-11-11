//
//  Fact.swift
//  BoutTime
//
//  Created by Alexey Papin on 12.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import Foundation

protocol FactType {
    var event: String { get }
    var year: Int { get }
    var link: String { get }
    
    func getTitle() -> String
}

struct Fact: FactType {
    let event: String
    let year: Int
    let link: String
    
    func getTitle() -> String {
        var title = self.event
        if title.characters.count > 200 { // max length 200 chars
            let startIndex = title.index(title.startIndex, offsetBy: 200)
            title = title.substring(to: startIndex)
        }
        return title
    }
}
