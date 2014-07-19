//
//  NSIndexSet+Intersection.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

extension NSIndexSet {
    func intersectionWithSet(set: NSIndexSet) -> NSMutableIndexSet {
        let finalSet = NSMutableIndexSet()
        self.enumerateIndexesUsingBlock({ (index, stop) in
            if set.containsIndex(index) {
                finalSet.addIndex(index)
            }
            })
        return finalSet
    }
}

func NSIndexSetDelta(oldSet: NSIndexSet?, newSet: NSIndexSet?) -> (additions: NSMutableIndexSet, deletions: NSMutableIndexSet) {
    var deletions: NSMutableIndexSet
    var additions: NSMutableIndexSet
    
    // Old: ABC
    // ∆(-)  B
    // ∆(+)    D
    // New: A CD
    
    // deletions = old - new
    // additions = new - old
    
    // Since new and old values are optional, there are four possible cases
    if let oldSet = oldSet {
        if let newSet = newSet {
            additions = newSet - oldSet
            deletions = oldSet - newSet
        } else {
            additions = NSMutableIndexSet()
            deletions = oldSet.mutableCopy() as NSMutableIndexSet
        }
    } else {
        if let newSet = newSet {
            additions = newSet.mutableCopy() as NSMutableIndexSet
            deletions = NSMutableIndexSet()
        } else {
            additions = NSMutableIndexSet()
            deletions = NSMutableIndexSet()
        }
    }
    return (additions, deletions)
}

@infix func -(left: NSIndexSet, right: NSIndexSet) -> NSMutableIndexSet {
    let indexSet = left.mutableCopy() as NSMutableIndexSet
    indexSet.removeIndexes(right)
    return indexSet
}

@infix func +(left: NSIndexSet, right: NSIndexSet) -> NSMutableIndexSet {
    let indexSet = left.mutableCopy() as NSMutableIndexSet
    indexSet.addIndexes(right)
    return indexSet
}
