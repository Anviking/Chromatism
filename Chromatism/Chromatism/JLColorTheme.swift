//
//  JLColorTheme.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

func UIColorRGB(r:Int, g:Int, b:Int) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
}

public enum JLColorTheme {
    case Default, Dusk, Other([JLTokenType: UIColor])
    
    public subscript(type: JLTokenType) -> UIColor? {
        return dictionary[type]
    }
    
    static let defaultTheme: [JLTokenType: UIColor] = [
        .Text:                         UIColor.blackColor(),
        .Background:                   UIColorRGB(255, 255, 255),
        .Comment:                      UIColorRGB(0, 131, 39),
        .DocumentationComment:         UIColorRGB(0, 131, 39),
        .DocumentationCommentKeyword:  UIColorRGB(0, 76, 29),
        .String:                       UIColorRGB(211, 45, 38),
        .Character:                    UIColorRGB(40, 52, 206),
        .Number:                       UIColorRGB(40, 52, 206),
        .Keyword:                      UIColorRGB(188, 49, 156),
        .Preprocessor:                 UIColorRGB(120, 72, 48),
        .URL:                          UIColorRGB(21, 67, 244),
        .Other:                        UIColorRGB(113, 65, 163),
        .OtherMethodNames :            UIColorRGB(112, 64, 166),
        .OtherClassNames :             UIColorRGB(112, 64, 166),
        .ProjectClassNames :           UIColorRGB(63, 110, 116),
        .ProjectMethodNames :          UIColorRGB(38, 71, 75)
    ]
    
    static let duskTheme: [JLTokenType: UIColor] = [
        .Text:                         UIColor.whiteColor(),
        .Background:                   UIColorRGB(30, 32, 40),
        .Comment:                      UIColorRGB(72, 190, 102),
        .DocumentationComment:         UIColorRGB(72, 190, 102),
        .DocumentationCommentKeyword:  UIColorRGB(72, 190, 102),
        .String:                       UIColorRGB(230, 66, 75),
        .Character:                    UIColorRGB(139, 134, 201),
        .Number:                       UIColorRGB(139, 134, 201),
        .Keyword:                      UIColorRGB(195, 55, 149),
        .Preprocessor:                 UIColorRGB(198, 124, 72),
        .URL:                          UIColorRGB(35, 63, 208),
        .Other:                        UIColorRGB(0, 175, 199),
        .OtherClassNames :             UIColorRGB(4,175,200),
        .OtherMethodNames :            UIColorRGB(4,175,200),
        .ProjectMethodNames :          UIColorRGB(131, 192, 87),
        .ProjectClassNames :           UIColorRGB(131, 192, 87)
    ]
    
    var dictionary: [JLTokenType: UIColor] {
    switch self {
    case .Default:
        return JLColorTheme.defaultTheme
    case .Dusk:
        return JLColorTheme.duskTheme
    case .Other(let dictionary):
        return dictionary
    default:
        break
        }
    }
}
