//
//  MainViewController.swift
//  Graph
//
//  Created by Jang Dong Min on 05/04/2020.
//  Copyright © 2020 jdm. All rights reserved.
//

import UIKit
import PDFKit

class MainViewController: UIViewController, UIGestureRecognizerDelegate {
    //
    // GraphViewModel -> setDefaultData()에 기본 데이터를 설정해놨습니다. (삭제하셔도 됩니다.)
    // graphView -> addLayer //그래프 추가
    // graphView -> addNode(layerIndex: 0, inputValue: 100) //노드 추가
    // graphView -> setbackgroundLineCount(count: 10) //백그라운드 라인 변경
    // graphView -> layerTitleChagne //그래프 title 값 변경
    // graphView -> nodeValueChange //그래프 node 값 변경
    //
    
    let viewModel = GraphViewModel()
     
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var containerTableView: ContainerTableView!
    @IBOutlet weak var plusButton: UIButton!
    
    var parentViewTopMargin: CGFloat = 0
    var selectPosY: CGFloat = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(beginEditingTextField), name: Notification.Name(rawValue: CustomTextField.BeginEditingTextFieldIdentifier), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
         
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPressGesture)
        
        bindViewModel()
    }
    
    func bindViewModel() {
        containerTableView.bindViewModel(viewModel: viewModel)
        
        self.viewModel.graphDataArrObserver.bindAndFire { [weak self] graphDataArr in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                //기본 데이터 세팅. (없어도 됩니다.)
                //GraphViewModel -> setDefaultData() 에 기본 데이터 세팅.
                self.graphView.removeAllData()

                for i in 0..<graphDataArr.count {
                    self.graphView.addLayer(layer: Layer(_type: graphDataArr[i].title, _color: .random, lineWidth: 2, node1: CGFloat(graphDataArr[i].dataArr[0]), node2: CGFloat(graphDataArr[i].dataArr[1]),   node3:  CGFloat(graphDataArr[i].dataArr[2])))

                    //기본 데이터 세팅. (없어도 됩니다.)
                    //기본 point 4개 삽입
                    if graphDataArr[i].dataArr.count > 3 {
                        self.graphView.addNode(layerIndex: i, inputValue: CGFloat(graphDataArr[i].dataArr[3]))
                    }
                }

                self.containerTableView.reloadData()
            }
        }
        
        self.viewModel.nodeDataObserver.bind { [weak self] (nodeValue) in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                //그래프 node 값이 변경된다면, 값을 수정합니다.
                self.graphView.nodeValueChange(layerIndex: nodeValue.0, nodeIndex: nodeValue.1, inputValue: CGFloat(nodeValue.2))
            }
        }
        
        self.viewModel.layerTitleObserver.bind { [weak self] (layerInfoTuple) in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                //그래프 title 값이 변경된다면, 값을 수정합니다.
                self.graphView.layerTitleChagne(layerIndex: layerInfoTuple.0, title: layerInfoTuple.1)
            }
        }

        self.viewModel.graphDataObserver.bind { [weak self] (graphData) in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                //그래프 layer를 추가합니다.
                self.graphView.addLayer(layer: Layer(_type: graphData.title, _color: .random, lineWidth: 2, node1: CGFloat(graphData.dataArr[0]), node2: CGFloat(graphData.dataArr[1]),   node3:  CGFloat(graphData.dataArr[2])))
                
                self.containerTableView.reloadData()
                
                if self.viewModel.graphDataArr.count > 0 {
                    //테이블 뷰 맨 아래로 이동.
                    let indexPath = IndexPath(row: self.viewModel.graphDataArr.count-1, section: 0)
                    self.containerTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
     
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async() { [weak self] in
            guard let `self` = self else { return }
            if self.graphView.viewRect != self.graphView.frame {
                //화면 회전, 사이즈 변경시 그래프 다시 그리기
                self.graphView.ReDraw(rect: self.graphView.frame)
            }
        }
        
        parentViewTopMargin = self.parentView.frame.origin.y
    }
    
    @IBAction func addButtonClick(_ sender: Any) {
//        self.graphView.addNode(layerIndex: 0, inputValue: 100) //노드 추가 테스트
//        self.graphView.setbackgroundLineCount(count: 10) //백그라운드 라인 변경
        self.viewModel.addLayer() //그래프 색은 랜덤.
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) -> Void {
        if gesture.state == .began {
            createPdfFromView(aView: graphView, saveToDocumentsWithFileName: "Graph")
        }
        else if gesture.state == .ended {
        }
    }
   
    @objc func beginEditingTextField(notification: Notification) {
        if let textField = notification.object as? CustomTextField {
            let selectRect = self.view.convert(self.containerTableView.rectForRow(at: IndexPath(item: textField.index, section: 0)), from: self.containerTableView)
            self.selectPosY = selectRect.origin.y + (selectRect.size.height) - (self.parentView.frame.origin.y)
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let limit = self.view.frame.size.height - keyboardSize.height - CustomTextField.toolbarHeight
            
            if limit < self.selectPosY {
                let move = self.selectPosY - limit
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.parentView.frame.origin.y = self.parentViewTopMargin
                    self.parentView.frame.origin.y -= move
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if self.parentView.frame.origin.y != parentViewTopMargin {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                
                self.parentView.frame.origin.y = self.parentViewTopMargin
            }
        }
    }
}

extension MainViewController: UIDocumentInteractionControllerDelegate {
    //PDF 생성!
    func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String) {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName + ".pdf"
            pdfData.write(toFile: documentsFileName, atomically: true)
            
            
            let document = PDFDocument(url: URL(fileURLWithPath: documentsFileName))!
            var metadata = document.documentAttributes!

            metadata[PDFDocumentAttribute.authorAttribute] = "JANG DONG MIN"
            metadata[PDFDocumentAttribute.creatorAttribute] = "JANG DONG MIN"
            metadata[PDFDocumentAttribute.producerAttribute] = "JANG DONG MIN"
            metadata[PDFDocumentAttribute.titleAttribute] = "JDM GRAPH SAMPLE"
            metadata[PDFDocumentAttribute.subjectAttribute] = "MAKE JANG DONG MIN"

//            metadata[PDFDocumentAttribute.creationDateAttribute] = Date().currentTimeZoneDate()
//            metadata[PDFDocumentAttribute.modificationDateAttribute] = Date().currentTimeZoneDate()

            metadata[PDFDocumentAttribute.keywordsAttribute] = "Report, JDM, JANG, DONG, MIN, GRAPH"
            document.documentAttributes = metadata
            document.write(to: URL(fileURLWithPath: documentsFileName))
            
            DispatchQueue.main.async {
                let docVC = UIDocumentInteractionController(url: URL(fileURLWithPath: documentsFileName))
                docVC.delegate = self
                docVC.presentPreview(animated: true)
            }
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }

    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }

}

