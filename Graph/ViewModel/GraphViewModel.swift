//
//  GraphViewModel.swift
//  Graph
//
//  Created by Paul Jang on 2020/04/08.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class GraphViewModel {
    var graphDataArr = [GraphData]()
    var graphDataArrObserver = GenericObserver<[GraphData]>([GraphData]())
    var graphDataObserver = GenericObserver<GraphData>(GraphData())
    var nodeDataObserver = GenericObserver<(Int, Int, Float)>((0, 0, 0))
    var layerTitleObserver = GenericObserver<(Int, String)>((0, ""))
    
    init() {
        //기본 데이터 세팅. (없어도 됩니다.)
        setDefaultData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getTextFieldValue), name: Notification.Name(rawValue: CustomTextField.CustomTextFieldIdentifier), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //기본 데이터 세팅. (없어도 됩니다.)
    //삭제하셔도 됩니다.
    private func setDefaultData() {
        graphDataArr.append(GraphData(title: "bitcoin", dataArr: [0, 230, 50, 400])) //삭제하셔도 됩니다.
        //graphDataArr.append(GraphData(title: "ethurim", dataArr: [0, 35, 200])) //삭제하셔도 됩니다.
        graphDataArrObserver.value = graphDataArr //삭제하셔도 됩니다.
    }
    
    //TextField 변경되었을때, 반응합니다.
    @objc private func getTextFieldValue(notification: Notification) {
        if let textField = notification.object as? CustomTextField {
            if textField.identifier == "ContainerTableView" {
                graphDataArr[textField.index].title = textField.text
                layerTitleObserver.value = (textField.index, textField.text!)
            } else {
                let value = textField.text?.CGFloatValue() ?? 0
                if graphDataArr[textField.index].dataArr[textField.tag] != Int(value) {
                    //textField 값 변경시
                    nodeDataObserver.value = (textField.index, textField.tag, Float(value))
                }
                graphDataArr[textField.index].dataArr[textField.tag] = Int(value)
            }
        }
    }
    
    //그래프 선을 추가합니다.
    //기본 0, 0, 0 으로 세팅.
    public func addLayer() {
        let graphData = GraphData(title: "", dataArr: [0, 0, 0])
        graphDataArr.append(graphData)
        graphDataObserver.value = graphData
    }
}
