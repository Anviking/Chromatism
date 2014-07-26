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
    
    override func invalidateAttributesInIndexes(indexSet: NSIndexSet, attributedString: NSMutableAttributedString) {
        cascade { $0.invalidateAttributesInIndexes(indexSet, attributedString: attributedString) }
    }
}

private extension JLScope {
    func cascade(block: (scope: JLScope) -> Void) {
        block(scope: self)
        for scope in subscopes {
            scope.cascade(block)
        }
    }
}
