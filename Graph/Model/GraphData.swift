//
//  GraphData.swift
//  Graph
//
//  Created by Paul Jang on 2020/04/07.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class GraphData: NSObject {
    var title: String!
    var dataArr = [Int]()
    
    override init() {}
    init(title: String, dataArr: [Int]) {
        self.title = title
        self.dataArr = dataArr
    }
}
