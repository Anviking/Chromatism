//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

protocol JLScopeDelegate {
    func scope(scope: JLScope, didPerformInAttributedString attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet, resultIndexSet: NSIndexSet)
}

class JLScope {
    
    init() { }
    init(scope: JLScope) {
        scope.addSubscope(self)
    }
    
    var editedIndexSet: NSIndexSet?
    
    // Store the result-indexSet until next perform to calculate deltas
    // This may not be a good idea, and JLScope's use of this property is different, JLToken should
    // probably conform to a protocol instead of subclass JLScope, but it's inconvenient at the same time
    var indexSet: NSMutableIndexSet = NSMutableIndexSet() {
    didSet  {
        let (additions, deletions) = NSIndexSetDelta(oldValue, indexSet)
    }
    }
    var subscopes: [JLScope] = []
    
    func addSubscope(subscope: JLScope) {
        self.subscopes += subscope
    }
    
    func perform(attributedString: NSMutableAttributedString, delegate: JLScopeDelegate) {
        perform(attributedString, delegate: delegate, parentIndexSet: NSIndexSet(indexesInRange: NSMakeRange(0, attributedString.length)))
    }
    
    func perform(attributedString: NSMutableAttributedString, delegate: JLScopeDelegate, parentIndexSet: NSIndexSet) {
        
        // If the indexSet-property is set, intersect it with the parent scope index set.
        var indexSet: NSMutableIndexSet
        if let editedIndexSet = self.editedIndexSet {
            indexSet = editedIndexSet.intersectionWithSet(parentIndexSet)
        } else {
            indexSet = parentIndexSet.mutableCopy() as NSMutableIndexSet
        }
        
        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        let indexSetCopy = indexSet.mutableCopy() as NSMutableIndexSet
        performSubscopes(attributedString, delegate: delegate, indexSet: indexSetCopy)
        
        self.indexSet = indexSet
    }
    
    // Will change indexSet
    func performSubscopes(attributedString: NSMutableAttributedString, delegate: JLScopeDelegate, indexSet: NSMutableIndexSet) {
        
        var lookForDiffs = false
        for scope in subscopes {
            if scope.editedIndexSet {
                lookForDiffs = true
            }
        }
        
        for scope in subscopes {
            scope.perform(attributedString, delegate: delegate, parentIndexSet: indexSet)
            indexSet.removeIndexes(scope.indexSet)
        }
    }
}
