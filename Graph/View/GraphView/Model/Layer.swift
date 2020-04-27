//
//  Layer.swift
//  Graph
//
//  Created by Jang Dong Min on 2020/04/06.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class Layer: NSObject {
    var index: Int!
    var type: String!
    var color: UIColor!
    var lineShapeLayer: CAShapeLayer!
    var circleShapeLayer: CAShapeLayer!
    var nodeArr = Array<Node>()
    
    init(_type: String, _color: UIColor, lineWidth: Int, node1: CGFloat = 0, node2: CGFloat = 0, node3: CGFloat = 0) {
        self.type = _type
        self.color = _color
        self.lineShapeLayer = CAShapeLayer()
        self.lineShapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        self.lineShapeLayer.strokeColor = _color.cgColor
        self.lineShapeLayer.lineWidth = CGFloat(lineWidth)
        
        self.circleShapeLayer = CAShapeLayer()
        self.circleShapeLayer.fillColor = UIColor.white.cgColor
        self.circleShapeLayer.strokeColor = _color.cgColor
        self.circleShapeLayer.lineWidth = CGFloat(lineWidth)
        
        //default 3개
        nodeArr.append(Node(_index: 0, _point: CGPoint(x: 0, y: node1), _color: self.color))
        nodeArr.append(Node(_index: 1, _point: CGPoint(x: 0, y: node2), _color: self.color))
        nodeArr.append(Node(_index: 2, _point: CGPoint(x: 0, y: node3), _color: self.color))
    }
    
    func addNode(node: CGFloat) {
        nodeArr.append(Node(_index: nodeArr.count, _point: CGPoint(x: 0, y: node), _color: self.color))
    }
}
