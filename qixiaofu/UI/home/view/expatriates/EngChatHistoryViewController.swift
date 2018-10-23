//
//  EngChatHistoryViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class EngChatHistoryViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "沟通历史"
        self.tableView.register(UINib.init(nibName: "EngJobChatHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "EngJobChatHistoryCell")
        self.tableView.separatorStyle = .none
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EngJobChatHistoryCell", for: indexPath) as! EngJobChatHistoryCell
        cell.parentVC = self
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }


}
