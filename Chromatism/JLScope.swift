//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLScope: Equatable {
    
    init() {
        
    }
    
    subscript(scopes: JLScope...) -> JLScope {
        self.subscopes = scopes
            return self
    }
    
    var attributedString: NSMutableAttributedString!
    var multiline = false
    var theme: ColorTheme?
    var delegate: JLNestedScopeDelegate?

    var indexSet = IndexSet()
    var subscopes = [JLScope]()
    
    func addSubscope(_ subscope: JLScope) {
        subscopes.append(subscope)
    }
    
    func perform() {
        var set = IndexSet(integersIn: NSMakeRange(0, attributedString.length).toRange()!)
        perform(&set)
    }
    
    func perform(_ indexSet: inout IndexSet) {

        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        self.indexSet = indexSet
        performSubscopes(attributedString, indexSet: indexSet)
        
    }
    
    // Will change indexSet
    func performSubscopes(_ attributedString: NSMutableAttributedString, indexSet: IndexSet) {
        var indexSet = indexSet
        var deletions = IndexSet()
        for scope in subscopes {
            scope.theme = theme
            
            let oldSet = scope.indexSet
            scope.invalidateAttributesInIndexes(indexSet)
            scope.perform(&indexSet)
            let newSet = scope.indexSet
            indexSet -= newSet
            if scope.multiline {
                deletions += NSIndexSetDelta(oldSet, newSet: newSet).deletions
            }
        }
        if deletions.count > 0 {
            var a = deletions + indexSet
            perform(&a)
        }
    }
    
    // MARK:
    
    func invalidateAttributesInIndexes(_ indexSet: IndexSet) {

    }
    
    func shiftIndexesAtLoaction(_ location: Int, by delta: Int) {
        indexSet.shift(startingAt: location, by: delta)
    }
    
    // MARK: Printable
    public var description: String {
        return "JLScope"
    }
    
}

public func ==(lhs: JLScope, rhs: JLScope) -> Bool {
    return lhs.subscopes == rhs.subscopes && lhs.indexSet == rhs.indexSet
}
