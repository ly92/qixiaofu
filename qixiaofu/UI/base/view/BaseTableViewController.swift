//
//  BaseTableViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/22.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import ESPullToRefresh
import SwiftyJSON

class BaseTableViewController: UITableViewController {

    lazy var emptyView : UIView = {
        let emptyView = UIView(frame: self.view.bounds)
        emptyView.backgroundColor = BG_Color
        
        let imgV = UIImageView(image:UIImage(named:"emptyimage"))
        imgV.x = emptyView.w / 2.0 - 62.5
        imgV.y = emptyView.h / 2.0 - 45
        imgV.w = 125
        imgV.h = 90
        
        emptyView.addSubview(imgV)
        
        return emptyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //视图在导航器中显示默认四边距离
        self.edgesForExtendedLayout = []
        if #available(iOS 11.0, *){
            self.tableView.contentInsetAdjustmentBehavior = .never
//            self.tableView.contentInset =
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }
    
    
    func stopRefresh() {
        LYProgressHUD.dismiss()
        self.tableView.es.stopLoadingMore()
        self.tableView.es.stopPullToRefresh()
    }
    
    func showEmptyView() {
        if self.view.subviews.contains(self.emptyView){
            self.view.bringSubview(toFront: self.emptyView)
        }else{
            self.view.addSubview(self.emptyView)
        }
    }
    
    func hideEmptyView() {
        if self.view.subviews.contains(self.emptyView){
            self.emptyView.removeFromSuperview()
        }
    }
    
//    // 视图是否自动旋转
//    override var shouldAutorotate : Bool {
//        get{
//            return false
//        }
//    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


