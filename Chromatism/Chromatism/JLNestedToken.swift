//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

// This class shows that there is a fundamental problem with JLScope. It two tokens matches next to each other the indexSet will merge them to one. Concidering relying on the attributedString instead.
class JLNestedToken: JLScope {
    
    var incrementingToken: JLToken
    var decrementingToken: JLToken
    
    init(incrementingToken: JLToken, decrementingToken: JLToken) {
        self.incrementingToken = incrementingToken
        self.decrementingToken = decrementingToken
        super.init()
    }
    

    override func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        incrementingToken.perform(attributedString, parentIndexSet: parentIndexSet)
        decrementingToken.perform(attributedString, parentIndexSet: parentIndexSet)
        
        var incrementingTokens: ()
        incrementingToken.indexSet.enumerateRangesUsingBlock({ (range, stop) in
            
            })
    }

   
}
