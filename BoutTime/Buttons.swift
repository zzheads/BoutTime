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

protocol FactButtonType {
    var eventButton: UIButton { get set }
    var upImage: UIImageView? { get }
    var downImage: UIImageView? { get }
    var upButton: UIButton? { get }
    var downButton: UIButton? { get }
    
    init(fact: FactType, index: Int, maxIndex: Int, target: Any?, action: Selector, view: UIView)
    func updateEventButton(fact: FactType)
    func select()
    func unSelect()
}

class FactButton: FactButtonType {
    var eventButton: UIButton
    var upImage: UIImageView?
    var downImage: UIImageView?
    var upButton: UIButton?
    var downButton: UIButton?

    // constants
    let titleColorSelected = UIColor(red: 8/255.0, green: 43/255.0, blue: 62/255.0, alpha: 1.0)
    let titleColorUnselected = UIColor(red: 8/255.0, green: 43/255.0, blue: 62/255.0, alpha: 0.5)
    let backgroundColor = UIColor.white

    required init(fact: FactType, index: Int, maxIndex: Int, target: Any?, action: Selector, view: UIView) {
        var x = 20
        let height = (Int(UIScreen.main.bounds.height) - 100 - 20 * maxIndex) / maxIndex
        let y = 20 + (height + 20) * index
        var width = Int(UIScreen.main.bounds.width) - 80
        let title = fact.getTitle()
        
        self.eventButton = UIButton(type: .system)
        self.eventButton.setTitle(title, for: .normal)
        self.eventButton.frame = CGRect(x: x, y: y, width: width, height: height)
        self.eventButton.setTitleColor(titleColorUnselected, for: .normal)
        self.eventButton.setTitleColor(titleColorSelected, for: .highlighted)
        self.eventButton.backgroundColor = backgroundColor
        self.eventButton.isHidden = false
        self.eventButton.layer.cornerRadius = 4
        self.eventButton.layer.masksToBounds = true
        self.eventButton.titleEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        self.eventButton.titleLabel?.numberOfLines = 0
        self.eventButton.titleLabel?.lineBreakMode = .byWordWrapping
        self.eventButton.tag = index
        self.eventButton.addTarget(target, action: action, for: .touchUpInside)
        view.addSubview(self.eventButton)
        
        x += width - 4
        width = 40
        let halfHeight = Int(height / 2)
        print("height = \(height), halfHeight = \(halfHeight), height - halfHeight = \(height - halfHeight)")
        
        switch index {
        case 0:
            self.upImage = nil
            self.downImage = getImage(image: SwapButtons.down_full.icon(), rect: CGRect(x: x, y: y, width: width, height: height))
            self.downImage?.highlightedImage = SwapButtons.down_full_selected.icon()
            break
        case 1..<maxIndex - 1:
            self.upImage = getImage(image: SwapButtons.up_half.icon(), rect: CGRect(x: x, y: y, width: width, height: halfHeight))
            self.downImage = getImage(image: SwapButtons.down_half.icon(), rect: CGRect(x: x, y: y + halfHeight, width: width, height: height - halfHeight))
            self.upImage?.highlightedImage = SwapButtons.up_half_selected.icon()
            self.downImage?.highlightedImage = SwapButtons.down_half_selected.icon()
            break
        case maxIndex - 1:
            self.upImage = getImage(image: SwapButtons.up_full.icon(), rect: CGRect(x: x, y: y, width: width, height: height))
            self.upImage?.highlightedImage = SwapButtons.up_full_selected.icon()
            self.downImage = nil
            break
        default:
            self.upImage = nil
            self.downImage = nil
            break
        }

        if let upImage = self.upImage {
            view.addSubview(upImage)
            self.upButton = UIButton(frame: upImage.frame)
            if let upButton = self.upButton {
                upButton.addTarget(target, action: action, for: .touchUpInside)
                upButton.isHidden = false
                upButton.tag = index
                view.addSubview(upButton)
            }
        } else {
            self.upButton = nil
        }

        if let downImage = self.downImage {
            view.addSubview(downImage)
            self.downButton = UIButton(frame: downImage.frame)
            if let downButton = self.downButton {
                downButton.addTarget(target, action: action, for: .touchUpInside)
                downButton.isHidden = false
                downButton.tag = -index
                view.addSubview(downButton)
            }
        } else {
            self.downButton = nil
        }
    }
    
    func updateEventButton(fact: FactType) {
        self.eventButton.setTitle(fact.getTitle(), for: .normal)
    }

    func select() {
        self.eventButton.isHighlighted = true
        if let upImage = self.upImage {
            upImage.isHighlighted = true
        }
        if let downImage = self.downImage {
            downImage.isHighlighted = true
        }
    }
    
    func unSelect() {
        self.eventButton.isHighlighted = false
        if let upImage = self.upImage {
            upImage.isHighlighted = false
        }
        if let downImage = self.downImage {
            downImage.isHighlighted = false
        }
    }
    
    // Helper methods
    
    func getImage(image: UIImage, rect: CGRect) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.frame = rect
        imageView.isHidden = false
        return imageView
    }
}

