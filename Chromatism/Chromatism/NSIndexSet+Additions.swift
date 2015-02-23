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

func NSIndexSetDelta(oldSet: NSIndexSet, newSet: NSIndexSet) -> (additions: NSMutableIndexSet, deletions: NSMutableIndexSet) {
    // Old: ABC
    // ∆(-)  B
    // ∆(+)    D
    // New: A CD
    
    // deletions = old - new
    // additions = new - old
    
    let additions = newSet - oldSet
    let deletions = oldSet - newSet

    return (additions, deletions)
}

func -(left: NSIndexSet, right: NSIndexSet) -> NSMutableIndexSet {
    let indexSet = left.mutableCopy() as! NSMutableIndexSet
    indexSet.removeIndexes(right)
    return indexSet
}

func +(left: NSIndexSet, right: NSIndexSet) -> NSMutableIndexSet {
    let indexSet = left.mutableCopy() as! NSMutableIndexSet
    indexSet.addIndexes(right)
    return indexSet
}

func -=(left: NSMutableIndexSet, right: NSIndexSet) {
    left.removeIndexes(right)
}

func +=(left: NSMutableIndexSet, right: NSIndexSet) {
    left.addIndexes(right)
}

func -=(left: NSMutableIndexSet, right: NSRange) {
    left.removeIndexesInRange(right)
}

func +=(left: NSMutableIndexSet, right: NSRange) {
    left.addIndexesInRange(right)
}

extension NSRange {
    var end: Int {
    return location + length
    }
    
    var start: Int {
    return location
    }
}