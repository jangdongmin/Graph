//
//  GenericObserver.swift
//  Graph
//
//  Created by Paul Jang on 2020/04/08.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation

class GenericObserver<T> {
    typealias Observer = (T) -> ()
    
    init(_ v:T) {
        self.value = v
    }
    
    var observer:Observer?
    var value:T {
        didSet{
            self.observer?(value)
        }
    }
    
    func bind(_ listenr:Observer?) {
        self.observer = listenr
    }
    
    func bindAndFire(_ observer:Observer?) {
        self.observer = observer
        self.observer?(value)
    }
}

