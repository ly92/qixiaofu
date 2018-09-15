//
//  CreditsViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/27.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CreditsViewController: BaseViewController {
    class func spwan() -> CreditsViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! CreditsViewController
    }
    
    @IBOutlet weak var topImgV: UIImageView!
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var expendBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    
    @IBOutlet weak var lineLeftDis: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ruleView: UIView!
    @IBOutlet weak var subRuleView: UIView!
    @IBOutlet weak var backBtnTopDis: NSLayoutConstraint!
    
    @IBOutlet weak var emptyImgV: UIView!
    fileprivate var curpage : NSInteger = 1
    
    fileprivate lazy var dataArray : NSMutableArray = {
        let dataArray = NSMutableArray()
        return dataArray
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "CreditsCell", bundle: Bundle.main), forCellReuseIdentifier: "CreditsCell")

        self.topImgV.animationImages = [#imageLiteral(resourceName: "Integral_background_3"),#imageLiteral(resourceName: "Integral_background_4"),#imageLiteral(resourceName: "Integral_background_5"),#imageLiteral(resourceName: "Integral_background_6"),#imageLiteral(resourceName: "Integral_background_7"),#imageLiteral(resourceName: "Integral_background_8"),#imageLiteral(resourceName: "Integral_background_9"),#imageLiteral(resourceName: "Integral_background_10")]
        self.topImgV.animationDuration = 2.0
        self.topImgV.startAnimating()
        
        //添加刷新
        self.addRefresh()
        
        self.loadData()
        
        self.subRuleView.layer.cornerRadius = 5
        self.ruleView.addTapAction(action: #selector(CreditsViewController.showRuleAction), target: self)
        if iphoneType() == "iPhone X"{
            self.backBtnTopDis.constant = 35
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
         UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.topImgV.stopAnimating()
    }

    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            self?.loadData()
        }
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            self?.loadData()
        }
    }
    
    func loadData() {
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        params["member_id"] = LocalData.getUserId()
        
        NetTools.requestData(type: .post, urlString: CreditsListApi, parameters: params, succeed: { (result, msg) in
            
            //停止刷新
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            
            self.creditsLbl.text = result["all_integral"].stringValue
            for subJson in result["list"].arrayValue{
                self.dataArray.add(subJson)
            }

            //判断是否可以加载更多
            if result["list"].arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //是否为空
            if self.dataArray.count > 0{
                self.emptyImgV.isHidden = true
            }else{
                self.emptyImgV.isHidden = false
            }
            
            //重加载tabble
            self.tableView.reloadData()
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
    }


    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showRuleAction() {
        self.ruleView.isHidden = !self.ruleView.isHidden
    }

    @IBAction func categoryBtnAction(_ btn: UIButton) {
        self.allBtn.isSelected = false
        self.expendBtn.isSelected = false
        self.incomeBtn.isSelected = false
        btn.isSelected = true
        self.lineLeftDis.constant = kScreenW / 3.0 * CGFloat(btn.tag)
        
        if self.allBtn.isSelected || self.incomeBtn.isSelected{
            self.curpage = 1
            self.loadData()
        }else{
            self.emptyImgV.isHidden = false
        }
        
    }


}


//MARK: -  UITableViewDelegate,UITableViewDataSource
extension CreditsViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditsCell", for: indexPath) as! CreditsCell
        if self.dataArray.count > indexPath.row{
            let jsonModel = self.dataArray[indexPath.row] as! JSON
            cell.typeLbl.text = jsonModel["sourceValue"].stringValue
            cell.timeLbl.text = Date.dateStringFromDate(format: Date.datePointFormatString(), timeStamps: jsonModel["addtime"].stringValue)
            cell.countLbl.text = "+" + jsonModel["integral"].stringValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
}



