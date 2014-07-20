//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLScope: NSObject, Printable {
    
    init() {
        super.init()
    }
    
    init(scope: JLScope) {
        super.init()
        scope.addSubscope(self)
    }
    
    var colorDictionary: Dictionary<JLTokenType, UIColor>?
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
        
        if clearWithTextColorBeforePerform {
            parentIndexSet.enumerateRangesUsingBlock({(range, stop) in
                let color = self.colorDictionary?[.Text]
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                })
        }
        
        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        let indexSetCopy = parentIndexSet.mutableCopy() as NSMutableIndexSet
        performSubscopes(attributedString, indexSet: indexSetCopy)
        
        self.indexSet = parentIndexSet.mutableCopy() as NSMutableIndexSet
    }
    
    // Will change indexSet
    func performSubscopes(attributedString: NSMutableAttributedString, indexSet: NSMutableIndexSet) {
        
        // In advance, see if we have to calculate deltas
        // If a scope is lazily evaluated with a editedIndexSet, it needs to listed
        var calculateDelta = false
        for scope in subscopes {
            if scope.editedIndexSet {
                calculateDelta = true
                break
            }
        }
        
        var deletions = NSMutableIndexSet()
        
        for (index, scope) in enumerate(subscopes) {
            scope.colorDictionary = colorDictionary
            if calculateDelta {
                if let editedIndexSet = scope.editedIndexSet {
                    let set = indexSet.intersectionWithSet(editedIndexSet) + deletions
                    println("set: \(set)")
                    scope.perform(attributedString, parentIndexSet: set)
                    indexSet -= scope.indexSet
                } else {
                    var oldSet = scope.indexSet
                    scope.perform(attributedString, parentIndexSet: indexSet)
                    var newSet = scope.indexSet
                    indexSet -= newSet
                    deletions += NSIndexSetDelta(oldSet, newSet).deletions
                    println("Deletions: \(deletions)")
                }
            } else {
                scope.perform(attributedString, parentIndexSet: indexSet)
                indexSet -= scope.indexSet
            }
        }
    }
    
    // Printable
    override var description: String {
    return "JLScope"
    }
}
