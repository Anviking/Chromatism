//
//  JLDocumentScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-20.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLDocumentScope: JLScope {
    
    override init() {
        super.init()
    }
    
    override subscript(scopes: JLScope...) -> JLDocumentScope {
        self.subscopes = scopes
        return self
    }
    
    override public func perform(_ indexSet: inout IndexSet)  {
        for range in indexSet.rangeView {
            if let color = self.theme?[.text] {
                self.attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(Range(range)))
            }
        }
        
        super.perform(&indexSet)
    }
    
    func cascadeAttributedString(_ attributedString: NSMutableAttributedString) {
        self.attributedString = attributedString
        cascade { $0.attributedString = attributedString }
    }

    override func invalidateAttributesInIndexes(_ indexSet: IndexSet) {
        cascade { $0.invalidateAttributesInIndexes(indexSet) }
    }
    
    override func shiftIndexesAtLoaction(_ location: Int, by delta: Int) {
        cascade { $0.shiftIndexesAtLoaction(location, by: delta) }
    }
    
    func cascade(_ block: (_ scope: JLScope) -> Void) {
        for scope in subscopes {
            cascade(block, scope: scope)
        }
    }
    
    private func cascade(_ block: (_ scope: JLScope) -> Void, scope: JLScope) {
        block(scope)
        for subscope in scope.subscopes {
            cascade(block, scope: subscope)
        }
    }
}
