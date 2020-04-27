//
//  GraphView.swift
//  Graph
//
//  Created by Jang Dong Min on 05/04/2020.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class GraphView: UIView {
    
    // backgroundSectionCount
    // (ex. 0~200, 200~400.. 몇개의 구간으로 나눌지)
    var backgroundSectionCount = 5  //변경 가능
    var backgroundLabelArr = [UILabel]()
    var backgroundCAShapeLayerArr = [CAShapeLayer]()
    var backgroundRect: CGRect?
    
    var guideLabelArr = [UILabel]()
    var guideView = UIView() //상단 가이드 화면
    let guideHeight:CGFloat = 40 //상단 가이드 높이.
    
    var layerArr = [Layer]()
    
    var viewRect: CGRect!
    var nodeMaxY: CGFloat = 0
    var animationSpeed: CGFloat = 0.1
    let circleUISize: CGFloat = 6 //원 크기
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewRect = frame
        loadXib()
    }
    
    private func loadXib() {
        let view = Bundle.main.loadNibNamed("GraphView", owner: self, options: nil)?.first as! UIView
        view.frame = self.frame
        viewRect = self.frame
        self.addSubview(view)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewRect = self.frame
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- public method
    //
    //layer 추가
    //parameter : layer 객체
    //return :
    //
    public func addLayer(layer: Layer) {
        layer.index = layerArr.count
        layerArr.append(layer)
        
        let MaxY = getMaxYFromNode([layer])
        
        if nodeMaxY < MaxY {
            nodeMaxY = MaxY
            
            backgroundRect = backgroundUIDraw(nodeMaxY, layerArr, backgroundSectionCount)
            linePositionChange(layers: layerArr, drawRect: backgroundRect!, MaxY: nodeMaxY)
        } else {
            backgroundRect = backgroundUIDraw(nodeMaxY, layerArr, backgroundSectionCount)
        }
        
        lineDraw(layer: layer, drawRect: backgroundRect, MaxY: nodeMaxY)
    }

    //
    //node point 추가
    //parameter : layer index, 추가할 값
    //return :
    //
    public func addNode(layerIndex: Int, inputValue: CGFloat) {
        if layerArr.count > layerIndex && backgroundRect != nil {
            let nodeIndex = layerArr[layerIndex].nodeArr.count
            layerArr[layerIndex].nodeArr.append(Node(_index: nodeIndex, _point: CGPoint(x: 0, y: inputValue), _color: layerArr[layerIndex].color))
            
            applyAnimation(layerIndex: layerIndex, nodeIndex: nodeIndex, layers: layerArr, MaxY: nodeMaxY, inputValue: inputValue, lineAni: true)
        }
    }
    
    //
    //graph node 변경
    //parameter : layer index, node index, 변경값
    //return :
    //
    public func nodeValueChange(layerIndex: Int, nodeIndex: Int, inputValue: CGFloat) {
        if layerArr.count > layerIndex && layerArr[layerIndex].nodeArr.count > nodeIndex && backgroundRect != nil {
            layerArr[layerIndex].nodeArr[nodeIndex].originalPoint.y = inputValue
            
            applyAnimation(layerIndex: layerIndex, nodeIndex: nodeIndex, layers: layerArr, MaxY: nodeMaxY, inputValue: inputValue, lineAni: false)
        }
    }
    
    //
    //title 변경
    //parameter : layer index, title
    //return :
    //
    public func layerTitleChagne(layerIndex: Int, title: String) {
        if layerArr.count > layerIndex {
            layerArr[layerIndex].type = title
            guideLabelArr[layerIndex].text = title
            guideView.removeFromSuperview()
            let _ = guideUIDraw(layerArr: layerArr, guideHeight: guideHeight)
        }
    }
    
    //
    //다시 그리기
    //parameter : 화면 크기
    //return :
    //
    public func ReDraw(rect: CGRect) {
        viewRect = rect
        removeBackground()
        removeGraphLayer(dataRemove: false)
        GraphDraw(layers: layerArr, sectionCount: backgroundSectionCount)
    }
    
    //
    //background 라인 수 변경
    //parameter : 라인 수
    //return :
    //
    public func setbackgroundLineCount(count: Int) {
        if layerArr.count > 0 {
            backgroundSectionCount = count
            backgroundRect = backgroundUIDraw(nodeMaxY, layerArr, backgroundSectionCount)
        }
    }
    
    public func removeAllData() {
        removeBackground()
        removeGraphLayer(dataRemove: true)
    }
}

//MARK:- private method
extension GraphView {
    //
    //그래프 통합 Draw method
    //parameter : Layer 객체 Array, (ex. 0~200, 200~400.. 몇개로 나눠져 있는지)
    //return :
    //
    private func GraphDraw(layers: [Layer], sectionCount: Int) {
        let MaxY = getMaxYFromNode(layers)
        backgroundRect = backgroundUIDraw(MaxY, layers, sectionCount)
        lineDraw(layers: layers, drawRect: backgroundRect, MaxY: MaxY)
    }

    //
    //그래프 선 여러개 Draw
    //parameter : Layer 객체 Array, 그려야할 CGRect 영역
    //return :
    //
    private func lineDraw(layers: [Layer], drawRect: CGRect?, MaxY: CGFloat) {
        if drawRect != nil && layers.count > 0 {
            for i in 0..<layers.count {
                layers[i].lineShapeLayer.removeFromSuperlayer()
                layers[i].circleShapeLayer.removeFromSuperlayer()
                                
                let paths = makePath(MaxY, layers[i].nodeArr, drawRect!)
                layers[i].lineShapeLayer.path = paths.0.cgPath
                layers[i].circleShapeLayer.path = paths.1
                
                self.layer.addSublayer(layers[i].lineShapeLayer)
                self.layer.addSublayer(layers[i].circleShapeLayer)
            }
        }
    }
    
    //
    //그래프 선 Draw
    //parameter : Layer 객체, 그려야할 CGRect 영역
    //return :
    //
    private func lineDraw(layer: Layer, drawRect: CGRect?, MaxY: CGFloat) {
        if drawRect != nil {
            layer.lineShapeLayer.removeFromSuperlayer()
            layer.circleShapeLayer.removeFromSuperlayer()
            
            let paths = makePath(MaxY, layer.nodeArr, drawRect!)
            layer.lineShapeLayer.path = paths.0.cgPath
            layer.circleShapeLayer.path = paths.1
            
            self.layer.addSublayer(layer.lineShapeLayer)
            self.layer.addSublayer(layer.circleShapeLayer)
        }
    }
    
    //
    //그래프 애니메이션 이동
    //parameter : Layer 객체, 그려야할 CGRect 영역, MaxY
    //return :
    //
    private func linePositionChange(layers: [Layer], drawRect: CGRect, MaxY: CGFloat) {
        if layers.count > 0 {
            for i in 0..<layers.count {
                let paths = makePath(MaxY, layers[i].nodeArr, drawRect)
                
                layers[i].lineShapeLayer.add(makeAnimation(to: paths.0.cgPath , from: layers[i].lineShapeLayer.path), forKey: "line")
                layers[i].circleShapeLayer.add(makeAnimation(to: paths.1, from: layers[i].circleShapeLayer.path ), forKey: "circle")
                
                layers[i].lineShapeLayer.path = paths.0.cgPath
                layers[i].circleShapeLayer.path = paths.1
            }
        }
    }
    
    //
    //그래프 Line 구성, 그려야할 CGRect 영역 비율에 맞춰 값을 변화시킨다.
    //parameter : Layer의 Node들 중 가장 큰 Y값, Node Array, 그려야할 CGRect 영역
    //return : 그래프 Line 에 대한 정보가 들어있는 UIBezierPath, Node Position에 circle 표시하기위한 CGMutablePath
    //
    private func makePath(_ MaxY: CGFloat, _ nodeArr: [Node], _ drawRect: CGRect) -> (UIBezierPath, CGMutablePath) {
        let path = UIBezierPath()
        let circlePath = CGMutablePath()
        
        for j in 0..<nodeArr.count {
            let sectionWidth: CGFloat = (drawRect.size.width) / CGFloat(nodeArr.count - 1)
            
            let PosX = drawRect.origin.x + (sectionWidth * CGFloat(j))
            var PosY: CGFloat = 0
            if nodeArr[j].originalPoint.y == 0 {
                PosY = drawRect.height + drawRect.origin.y
            } else {
                PosY = drawRect.height - (drawRect.height * nodeArr[j].originalPoint.y / MaxY) + drawRect.origin.y
            }
             
            nodeArr[j].drawPoint = CGPoint(x: PosX, y: PosY)
            
            if j == 0 {
                path.move(to: CGPoint(x: PosX, y: PosY))
            } else {
                path.addLine(to: CGPoint(x: PosX, y: PosY))
            }

            let size:CGFloat = 6
            circlePath.addPath(UIBezierPath(roundedRect: CGRect(x: PosX - size/2 , y: PosY - size/2, width: size, height: size), cornerRadius: size).cgPath)
        }

        return (path, circlePath)
    }
     
    //
    //상단 가이드 UI
    //parameter : Layer 객체 Array, Node Array, 가이드 화면 높이 값,
    //return : (line, circle) layer Array, UILabel Array
    //
    private func guideUIDraw(layerArr: [Layer], guideHeight: CGFloat) -> ([CAShapeLayer], [UILabel]) {
        var shapeLayerArr = [CAShapeLayer]()
        var labelArr = [UILabel]()
        
        var PosX: CGFloat = 0
        
        guideView.removeFromSuperview()
        guideView = UIView()
        for layer in layerArr {
            if PosX != 0 {
                PosX += 5
            }
            
            //line
            let lineWidth: CGFloat = 10
            let shapeLayer = makeLine(startX: PosX, startY: guideHeight / 2, endX: PosX + lineWidth, endY: guideHeight / 2, color: layer.color)
            PosX += lineWidth

            shapeLayerArr.append(shapeLayer)
            guideView.layer.addSublayer(shapeLayer)

            //circle
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.fillColor = UIColor.white.cgColor
            circleShapeLayer.strokeColor = layer.color.cgColor
            circleShapeLayer.lineWidth = CGFloat(1)
            
            let size = circleUISize
            circleShapeLayer.path = UIBezierPath(roundedRect: CGRect(x: PosX - (lineWidth / 2) - size / 2 , y: guideHeight / 2 - size / 2, width: size, height: size), cornerRadius: size).cgPath
            shapeLayerArr.append(circleShapeLayer)
            guideView.layer.addSublayer(circleShapeLayer)
            
            
            //Label
            PosX += 5
            let label = makeLabel(title: layer.type, fontSize: 10, textAlignment: .center)
            
            let labelWidth = label.frame.size.width
            let labelHeight = label.frame.size.height
            label.frame = CGRect(x: PosX, y: guideHeight / 2 - label.frame.size.height / 2, width: labelWidth, height: labelHeight)

            labelArr.append(label)
            guideView.addSubview(label)
            
            PosX += labelWidth
        }
        
        guideView.frame = CGRect(x: viewRect.size.width / 2 - PosX / 2, y: 0, width: PosX, height: guideHeight)
        self.addSubview(guideView)
        
        return (shapeLayerArr, labelArr)
    }
    
    //
    //background 화면 구성
    //parameter : Layer의 Node들 중 가장 큰 Y값, (ex. 0~200, 200~400.. 몇개로 나눠져 있는지)
    //return : 그래프를 표시해야할 실제 영역을 return 한다
    //
    private func backgroundUIDraw(_ MaxY: CGFloat, _ layers: [Layer], _ sectionCount: Int) -> (CGRect) {
        removeBackground()

        let tuple = guideUIDraw(layerArr: layers, guideHeight: guideHeight)
        guideLabelArr.append(contentsOf: tuple.1)
        backgroundCAShapeLayerArr.append(contentsOf: tuple.0)
         
        var lineStartPosX: CGFloat = 0
        let lineRectLeftMargin: CGFloat = 10
        let sectionHeight: CGFloat = MaxY / CGFloat(sectionCount - 1)
        var viewSectionHeight: CGFloat = 0
        var labelHeightHalf: CGFloat = 0

        for i in 0..<sectionCount {
            let label = makeLabel(title: "\(Int(MaxY - (sectionHeight * CGFloat(i))))")
            viewSectionHeight = ((viewRect.size.height - guideHeight) - label.frame.size.height) / CGFloat(sectionCount - 1)
            
            if lineStartPosX == 0 {
                lineStartPosX = label.frame.origin.x + label.frame.size.width + lineRectLeftMargin
            }

            label.frame = CGRect(x: 0, y: guideHeight + viewSectionHeight * CGFloat(i), width: lineStartPosX - lineRectLeftMargin, height: label.frame.size.height)
            backgroundLabelArr.append(label)
            self.addSubview(label)

            
            labelHeightHalf = label.frame.size.height / 2
            
            //circle UI가 영역을 벗어난다.
            let shapeLayer = makeLine(startX: lineStartPosX, startY: label.frame.origin.y + labelHeightHalf, endX: viewRect.size.width - circleUISize, endY: label.frame.origin.y + labelHeightHalf)
            backgroundCAShapeLayerArr.append(shapeLayer)
            self.layer.addSublayer(shapeLayer)
        }
        
        //circle UI가 영역을 벗어난다.
        return (CGRect(x: lineStartPosX, y: guideHeight + labelHeightHalf, width: (viewRect.size.width - lineStartPosX - circleUISize), height: viewSectionHeight * CGFloat(sectionCount - 1)))
    }
    
    private func makeLabel(title: String, fontSize: CGFloat = 12, textAlignment: NSTextAlignment = .right) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = title
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.sizeToFit()
        label.frame.size = CGSize(width: label.frame.size.width+2, height: label.frame.size.height)
        label.textAlignment = textAlignment
        return label
    }
    
    private func makeLine(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat, color: UIColor = .gray) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
    
    //
    //애니메이션을 전부 또는 하나만 적용할지 판단
    //parameter : Layer Index, Layer Array
    //return :
    //
    private func applyAnimation(layerIndex: Int, nodeIndex: Int, layers: [Layer], MaxY: CGFloat, inputValue: CGFloat, lineAni: Bool) {
        if MaxY < inputValue {
            nodeMaxY = inputValue
            //전부다 애니메이션
            backgroundRect = backgroundUIDraw(inputValue, layers, backgroundSectionCount)
        } else {
            //하나만 애니메이션 주자
            nodeMaxY = getMaxYFromNode(layers)
            backgroundRect = backgroundUIDraw(nodeMaxY, layers, backgroundSectionCount)
        }
          
        linePositionChange(layers: layers, drawRect: backgroundRect!, MaxY: nodeMaxY)
    }
 
    //
    //animation 제작
    //parameter : line, circle의 CGPath
    //return : CABasicAnimation 객체
    //
    private func makeAnimation(to: CGPath, from: CGPath?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.duration = CFTimeInterval(animationSpeed)
        if from != nil {
            animation.fromValue = from
        }
        animation.toValue = to
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    //
    //입력 받은 node들 중 가장 큰 Y 값을 구한다.
    //parameter : layer array
    //return : 가장 큰 Y값
    //
    private func getMaxYFromNode(_ layers: [Layer]) -> CGFloat {
        var MaxY:CGFloat = 0
        for layer in layers {
            for node in layer.nodeArr {
                if MaxY < node.originalPoint.y {
                    MaxY = node.originalPoint.y
                }
            }
        }
        return MaxY
    }
    
    private func removeBackground() {
        removeLabel()
        removeBackgroundShapeLayer()
    }
    
    private func removeGraphLayer(dataRemove: Bool) {
        for layer in layerArr {
            layer.lineShapeLayer.removeAllAnimations()
            layer.lineShapeLayer.removeFromSuperlayer()
            
            layer.circleShapeLayer.removeAllAnimations()
            layer.circleShapeLayer.removeFromSuperlayer()
        }
        
        if dataRemove {
            layerArr.removeAll()
        }
    }
   
    private func removeLabel() {
        for label in backgroundLabelArr {
            label.removeFromSuperview()
        }
        
        for label in guideLabelArr {
            label.removeFromSuperview()
        }
        
        backgroundLabelArr.removeAll()
        guideLabelArr.removeAll()
    }
   
    private func removeBackgroundShapeLayer() {
        for layer in backgroundCAShapeLayerArr {
            layer.removeFromSuperlayer()
        }
        backgroundCAShapeLayerArr.removeAll()
    }
}
