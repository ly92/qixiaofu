//
//  ChatOrRecommendListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/22.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class ChatOrRecommendListViewController: BaseViewController {
    class func spwan() -> ChatOrRecommendListViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! ChatOrRecommendListViewController
    }
    
    var isChatHistory = false
    
    @IBOutlet weak var remindLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "RecommendEngCell", bundle: Bundle.main), forCellReuseIdentifier: "RecommendEngCell")
        self.tableView.register(UINib.init(nibName: "JobChatHistoryCell", bundle: Bundle.main), forCellReuseIdentifier: "JobChatHistoryCell")
        
        if self.isChatHistory{
            self.navigationItem.title = "沟通历史"
        }else{
            self.navigationItem.title = "推荐工程师"
        }
    }
    
    
    @IBAction func buyChat() {
        let buyVC = BuyChatViewController.spwan()
        self.navigationController?.pushViewController(buyVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ChatOrRecommendListViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isChatHistory{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobChatHistoryCell", for: indexPath) as! JobChatHistoryCell
            cell.parentVC = self
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendEngCell", for: indexPath) as! RecommendEngCell
            cell.parentVC = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isChatHistory{
            return 120
        }else{
            return 70
        }
    }
    
    
    
    
}
