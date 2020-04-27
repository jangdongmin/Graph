//
//  Node.swift
//  Graph
//
//  Created by Jang Dong Min on 2020/04/06.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class Node: NSObject {
    var index: Int!
    var originalPoint: CGPoint!
    var drawPoint: CGPoint!
    var color: UIColor!
    
    override init(){}
    init(_index: Int, _point: CGPoint, _color: UIColor) {
        self.index = _index
        self.originalPoint = _point
        self.color = _color
        self.drawPoint = CGPoint(x: 0, y: 0)
    }
}
