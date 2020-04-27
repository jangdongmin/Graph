//
//  ContentTableView.swift
//  Graph
//
//  Created by Paul Jang on 2020/04/07.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class ContentTableView: UITableView {
    var viewModel: GraphViewModel!
    var index = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.delegate = self
        self.dataSource = self
    }
    
    public func bindViewModel(viewModel: GraphViewModel) {
        self.viewModel = viewModel
    }
}

extension ContentTableView: UITableViewDelegate {

}

extension ContentTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel == nil {
            return 0
        }
        return self.viewModel.graphDataArr[self.index].dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContentTableViewCell =  tableView.dequeueReusableCell(withIdentifier: String(describing: ContentTableViewCell.self),
        for: indexPath) as! ContentTableViewCell
        
        cell.numberTextField.text = "\(self.viewModel.graphDataArr[self.index].dataArr[indexPath.row])"
        cell.numberTextField.identifier = "ContentTableView"
        cell.numberTextField.tag = indexPath.row
        cell.numberTextField.index = index
        
        return cell
    }
}
