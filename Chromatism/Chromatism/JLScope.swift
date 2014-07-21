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
    
    var indexSet = NSMutableIndexSet()
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
        
        // If a subscope is "lazy" (has a set editedIndexSet), we must check sibling scopes for deletions.
        // If "*/" is removed, the comment token will not match, and we see that some indexes where deleted for that token.
        // Then we just tell the "lazy" scope to perform in those indexes
        
        var deletions = NSMutableIndexSet()
        for (index, scope) in enumerate(subscopes) {
            scope.colorDictionary = colorDictionary
            if containsSubscopeWithEditedIndexSet {
                if let editedIndexSet = scope.editedIndexSet {
                    let set = indexSet.intersectionWithSet(editedIndexSet) + deletions
                    scope.perform(attributedString, parentIndexSet: set)
                    indexSet -= scope.indexSet
                } else {
                    var oldSet = scope.indexSet
                    scope.perform(attributedString, parentIndexSet: indexSet)
                    var newSet = scope.indexSet
                    indexSet -= newSet
                    deletions += NSIndexSetDelta(oldSet, newSet).deletions
                }
            } else {
                scope.perform(attributedString, parentIndexSet: indexSet)
                println("Removing indexSet:\(scope.indexSet)")
                indexSet -= scope.indexSet
                println(indexSet)
            }
        }
    }
    
    var containsSubscopeWithEditedIndexSet: Bool {
    for scope in subscopes {
        if scope.editedIndexSet {
            return true
        }
        }
        return false
    }
    
    // Printable
    override var description: String {
    return "JLScope"
    }
}

extension JLScope {
    subscript(scopes: JLScope...) -> JLScope {
        self.subscopes = scopes
        return self
    }
}
