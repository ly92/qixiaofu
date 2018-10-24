//
//  MyJobListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class MyJobListViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的招聘"

    self.tableView.register(UINib.init(nibName: "JobCell", bundle: Bundle.main), forCellReuseIdentifier: "JobCell")
        
        
    }

    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath)


        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let jobDetailVC = JobDetailViewController.spwan()
        jobDetailVC.idType = 2
        self.navigationController?.pushViewController(jobDetailVC, animated: true)
    }


}
