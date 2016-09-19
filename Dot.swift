//
//  Dot.swift
//  softly
//
//  Created by Michael Stein on 6/6/16.
//  Copyright © 2016 Mike Stein Online. All rights reserved.
//

import UIKit

class Dot: UIView {
    var north:Dot?
    var south:Dot?
    var east:Dot?
    var west:Dot?

    
    var color: UIColor {
        didSet {
            self.backgroundColor = color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) not realz")
    }
    
    init(myColor:UIColor, frame:CGRect) {
        self.color = myColor
        super.init(frame:frame)
        //self.userInteractionEnabled = true
    
    }
    
    func beingTouched() {
        self.color = UIColor.redColor()
    }
    

    
    

}
