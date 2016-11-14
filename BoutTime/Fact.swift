//
//  Fact.swift
//  BoutTime
//
//  Created by Alexey Papin on 12.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import Foundation

struct Fact {
    let event: String
    let year: Int
    let link: String
    
    var title: String {
        var title = self.event
        if title.characters.count > 200 { // max length 200 chars
            let startIndex = title.index(title.startIndex, offsetBy: 200)
            title = title.substring(to: startIndex)
        }
        return title
    }
}
