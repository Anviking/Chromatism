//
//  JLScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLScope {
    
    init(attributedString: NSMutableAttributedString) {
        self.attributedString = attributedString
    }
    
    init(scope: JLScope) {
        self.attributedString = scope.attributedString
        scope.addSubscope(self)
    }
    
    var indexSet: NSIndexSet?
    var attributedString: NSMutableAttributedString
    
    var subscopes: [JLScope] = []
    
    func addSubscope(subscope: JLScope) {
        self.subscopes += subscope
    }
    
    func perform() {
        perform(inIndexSet: NSIndexSet(indexesInRange: NSMakeRange(0, attributedString.length)))
    }
    
    func perform(inIndexSet parentIndexSet: NSIndexSet) -> NSIndexSet {
        
        // If the indexSet-property is set, intersect it with the parent scope index set.
        var indexSet: NSMutableIndexSet
        if let propertyIndexSet = self.indexSet {
            indexSet = propertyIndexSet.intersectionWithSet(parentIndexSet)
        } else {
            indexSet = parentIndexSet.mutableCopy() as NSMutableIndexSet
        }
        
        // Create a copy of the indexSet and call perform to subscopes
        // The results of the subscope is removed from the indexSet copy before the next subscope is performed
        let indexSetCopy = indexSet.mutableCopy() as NSMutableIndexSet
        performSubscopesInIndexSet(indexSetCopy)
        
        return indexSet
    }
    
    func performSubscopesInIndexSet(indexSet: NSMutableIndexSet) {
        for scope in self.subscopes {
            scope.attributedString = attributedString
            indexSet.removeIndexes(scope.perform(inIndexSet: indexSet))
        }
    }
}
