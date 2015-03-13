//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLScope: NSObject, Printable, Equatable {
    override init() {
        super.init()
    }
    
    subscript(scopes: JLScope...) -> JLScope {
        self.subscopes = scopes
            return self
    }
    
    var attributedString: NSMutableAttributedString!
    var multiline = false
    var theme: JLColorTheme?
    var delegate: JLNestedScopeDelegate?

    var indexSet = NSMutableIndexSet()
    var subscopes = [JLScope]()
    
    func addSubscope(subscope: JLScope) {
        subscopes.append(subscope)
    }
    
    func perform() {
        perform(NSIndexSet(indexesInRange: NSMakeRange(0, attributedString.length)))
    }
    
    func perform(indexSet: NSIndexSet) {

        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        let indexSetCopy = indexSet.mutableCopy() as NSMutableIndexSet
        performSubscopes(attributedString, indexSet: indexSetCopy)
        self.indexSet = indexSet.mutableCopy() as NSMutableIndexSet
    }
    
    // Will change indexSet
    func performSubscopes(attributedString: NSMutableAttributedString, indexSet: NSMutableIndexSet) {
        
        var deletions = NSMutableIndexSet()
        for (index, scope) in enumerate(subscopes) {
            scope.theme = theme
            
            var oldSet = scope.indexSet
            scope.invalidateAttributesInIndexes(indexSet)
            scope.perform(indexSet)
            var newSet = scope.indexSet
            
            indexSet -= newSet
            if scope.multiline {
                deletions += NSIndexSetDelta(oldSet, newSet).deletions
            }
        }
        if deletions.count > 0 {
            perform(deletions + indexSet)
        }
    }
    
    // MARK:
    
    func invalidateAttributesInIndexes(indexSet: NSIndexSet) {

    }
    
    func shiftIndexesAtLoaction(location: Int, by delta: Int) {
        indexSet.shiftIndexesStartingAtIndex(location, by: delta)
    }
    
    // MARK: Printable
    override public var description: String {
    return "JLScope"
    }
    
}

public func ==(lhs: JLScope, rhs: JLScope) -> Bool {
    return lhs.subscopes == rhs.subscopes && lhs.indexSet == rhs.indexSet
}
