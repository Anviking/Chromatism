//
//  JLDocumentScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-20.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLDocumentScope: JLScope {
    
    init() {
        super.init()
        clearWithTextColorBeforePerform = true
    }
    
    func cascadeAttributedString(attributedString: NSMutableAttributedString) {
        self.attributedString = attributedString
        cascade { $0.attributedString = attributedString }
    }
    
    override func invalidateAttributesInIndexes(indexSet: NSIndexSet) {
        cascade { $0.invalidateAttributesInIndexes(indexSet) }
    }
    
    override func shiftIndexesAtLoaction(location: Int, by delta: Int) {
        cascade { $0.shiftIndexesAtLoaction(location, by: delta) }
    }
    
    private func cascade(block: (scope: JLScope) -> Void) {
        for scope in subscopes {
            cascade(block, scope: scope)
        }
    }
    
    private func cascade(block: (scope: JLScope) -> Void, scope: JLScope) {
        block(scope: scope)
        for subscope in scope.subscopes {
            cascade(block, scope: subscope)
        }
    }
}