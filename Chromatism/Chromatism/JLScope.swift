//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLScope: NSObject {
    
    init() {
        super.init()
    }
    
    init(scope: JLScope) {
        super.init()
        scope.addSubscope(self)
    }
    
    var colorDictionary: Dictionary<JLTokenType, UIColor>?
    var multiline = false
    var editedIndexSet: NSIndexSet?
    
    // Will set the color to .Text in this scope's parentIndexSet before performing.
    var clearWithTextColorBeforePerform = false
    
    // Store the result-indexSet until next perform to calculate deltas
    // This may not be a good idea, and JLScope's use of this property is different, JLToken should
    // probably conform to a protocol instead of subclass JLScope, but it's inconvenient at the same time
    var indexSet: NSMutableIndexSet = NSMutableIndexSet() {
    didSet  {
        let (additions, deletions) = NSIndexSetDelta(oldValue, indexSet)
    }
    }
    var subscopes = [JLScope]()
    
    func addSubscope(subscope: JLScope) {
        self.subscopes += subscope
    }
    
    func perform(attributedString: NSMutableAttributedString) {
        perform(attributedString, parentIndexSet: NSIndexSet(indexesInRange: NSMakeRange(0, attributedString.length)))
    }
    
    func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        // If the indexSet-property is set, intersect it with the parent scope index set.
        var indexSet: NSMutableIndexSet
        if let editedIndexSet = self.editedIndexSet {
            indexSet = editedIndexSet.intersectionWithSet(parentIndexSet)
        } else {
            indexSet = parentIndexSet.mutableCopy() as NSMutableIndexSet
        }
        
        if clearWithTextColorBeforePerform {
            indexSet.enumerateRangesUsingBlock({(range, stop) in
                let color = self.colorDictionary?[.Text]
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                })
        }
        
        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        let indexSetCopy = indexSet.mutableCopy() as NSMutableIndexSet
        performSubscopes(attributedString, indexSet: indexSetCopy)
        
        self.indexSet = indexSet
    }
    
    // Will change indexSet
    func performSubscopes(attributedString: NSMutableAttributedString, indexSet: NSMutableIndexSet) {
        for scope in subscopes {
            scope.colorDictionary = colorDictionary
            if scope.multiline {
                scope.perform(attributedString, parentIndexSet: indexSet)
            } else {
                scope.perform(attributedString, parentIndexSet: indexSet)
                indexSet.removeIndexes(scope.indexSet)
            }
        }
    }
}
