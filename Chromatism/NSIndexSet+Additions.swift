//
//  NSIndexSet+Intersection.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

func NSIndexSetDelta(_ oldSet: IndexSet, newSet: IndexSet) -> (additions: IndexSet, deletions: IndexSet) {
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

func -(left: IndexSet, right: IndexSet) -> IndexSet {
    var indexSet = left
    for range in right.rangeView {
        indexSet.remove(integersIn: Range(range))
    }
    return indexSet
}

func +(left: IndexSet, right: IndexSet) -> IndexSet {
    var indexSet = left
    for range in right.rangeView {
        indexSet.insert(integersIn: Range(range))
    }
    return indexSet
}

func -=(left: inout IndexSet, right: IndexSet) {
    left = left - right
}

func +=(left: inout IndexSet, right: IndexSet) {
    left = left + right
}

func -=(left: inout IndexSet, right: Range<Int>) {
    left.remove(integersIn: right)
}

func +=(left: inout IndexSet, right: Range<Int>) {
    left.insert(integersIn: right)
}

extension NSRange {
    var end: Int {
    return location + length
    }
    
    var start: Int {
    return location
    }
}
