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
