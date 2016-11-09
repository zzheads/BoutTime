//
//  Buttons.swift
//  BoutTime
//
//  Created by Alexey Papin on 09.11.16.
//  Copyright © 2016 zzheads. All rights reserved.
//

import UIKit

enum SwapButtons: String {
    case up_half
    case up_half_selected
    case up_full
    case up_full_selected
    case down_half
    case down_half_selected
    case down_full
    case down_full_selected
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return UIImage(named: "Default")!
        }
    }
}

struct FactButton {
    var eventButton: UIButton
    var upButton: UIButton?
    var downButton: UIButton?
}

