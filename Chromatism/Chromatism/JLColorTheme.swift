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
    
    private static let defaultTheme: [JLTokenType: UIColor] = [
        .Text:                         UIColor.blackColor(),
        .Background:                   UIColorRGB(255, g: 255, b: 255),
        .Comment:                      UIColorRGB(0, g: 131, b: 39),
        .DocumentationComment:         UIColorRGB(0, g: 131, b: 39),
        .DocumentationCommentKeyword:  UIColorRGB(0, g: 76, b: 29),
        .String:                       UIColorRGB(211, g: 45, b: 38),
        .Character:                    UIColorRGB(40, g: 52, b: 206),
        .Number:                       UIColorRGB(40, g: 52, b: 206),
        .Keyword:                      UIColorRGB(188, g: 49, b: 156),
        .Preprocessor:                 UIColorRGB(120, g: 72, b: 48),
        .URL:                          UIColorRGB(21, g: 67, b: 244),
        .OtherClassNames:              UIColorRGB(92, g: 38, b: 153),
        .OtherProperties:              UIColorRGB(92, g: 38, b: 153),
        .OtherMethodNames:             UIColorRGB(46, g: 13, b: 110),
        .OtherConstants:               UIColorRGB(46, g: 13, b: 110),
        .ProjectClassNames:            UIColorRGB(63, g: 110, b: 116),
        .ProjectProperties:            UIColorRGB(63, g: 110, b: 116),
        .ProjectConstants:             UIColorRGB(38, g: 71, b: 75),
        .ProjectMethodNames:           UIColorRGB(38, g: 71, b: 75)
    ]
    
    private static let duskTheme: [JLTokenType: UIColor] = [
        .Text:                         UIColor.whiteColor(),
        .Background:                   UIColorRGB(30, g: 32, b: 40),
        .Comment:                      UIColorRGB(72, g: 190, b: 102),
        .DocumentationComment:         UIColorRGB(72, g: 190, b: 102),
        .DocumentationCommentKeyword:  UIColorRGB(72, g: 190, b: 102),
        .String:                       UIColorRGB(230, g: 66, b: 75),
        .Character:                    UIColorRGB(139, g: 134, b: 201),
        .Number:                       UIColorRGB(139, g: 134, b: 201),
        .Keyword:                      UIColorRGB(195, g: 55, b: 149),
        .Preprocessor:                 UIColorRGB(198, g: 124, b: 72),
        .URL:                          UIColorRGB(35, g: 63, b: 208),
        .OtherClassNames:              UIColorRGB(4, g: 175, b: 200),
        .OtherMethodNames:             UIColorRGB(4, g: 175, b: 200),
        .OtherConstants:               UIColorRGB(4, g: 175, b: 200),
        .OtherProperties:              UIColorRGB(4, g: 175, b: 200),
        .ProjectMethodNames:           UIColorRGB(131, g: 192, b: 87),
        .ProjectClassNames:            UIColorRGB(131, g: 192, b: 87),
        .ProjectConstants:             UIColorRGB(131, g: 192, b: 87),
        .ProjectProperties:            UIColorRGB(131, g: 192, b: 87)
        
    ]
    
    var dictionary: [JLTokenType: UIColor] {
        switch self {
        case .Default:
            return JLColorTheme.defaultTheme
        case .Dusk:
            return JLColorTheme.duskTheme
        case .Other(let dictionary):
            return dictionary
        }
    }
}
