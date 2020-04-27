//
//  ContainerTableView.swift
//  Graph
//
//  Created by Paul Jang on 2020/04/07.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class ContainerTableView: UITableView {
    var viewModel: GraphViewModel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.dataSource = self
    }
    
    public func bindViewModel(viewModel: GraphViewModel) {
        self.viewModel = viewModel
    }
    
    public func reload() {
        self.reloadData()
    }
}

extension ContainerTableView: UITableViewDelegate {

}

extension ContainerTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel == nil {
            return 0
        }
        return self.viewModel.graphDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContainerTableViewCell =  tableView.dequeueReusableCell(withIdentifier: String(describing: ContainerTableViewCell.self),
        for: indexPath) as! ContainerTableViewCell
        
        cell.titleTextField.text = self.viewModel.graphDataArr[indexPath.row].title
        cell.titleTextField.identifier = "ContainerTableView"
        cell.titleTextField.index = indexPath.row
        cell.contentTableView.index = indexPath.row
        cell.contentTableView.bindViewModel(viewModel: viewModel)
        cell.contentTableView.reloadData()
         
        return cell
    }
}


