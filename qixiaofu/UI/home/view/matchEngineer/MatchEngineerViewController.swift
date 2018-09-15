//
//  MatchEngineerViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/7.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MatchEngineerViewController: BaseViewController {
    class func spwan() -> MatchEngineerViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! MatchEngineerViewController
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var sureBtnH: NSLayoutConstraint!
    
    var bill_id = ""
    fileprivate var curpage : NSInteger = 1
    
    fileprivate lazy var engListArray : Array<JSON> = {
        let array = Array<JSON>()
        return array
    }()
    
    fileprivate lazy var selectedArray : Array<String> = {
        let array = Array<String>()
        return array
    }()
    fileprivate var chooseItem = UIBarButtonItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "匹配工程师"
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(MatchEngineerViewController.backClick))
        
        let mapItem = UIBarButtonItem.init(title: "地图", style: .plain, target: self, action: #selector(MatchEngineerViewController.mapItemAction))
        mapItem.tintColor = UIColor.RGBS(s: 33)
        self.chooseItem = UIBarButtonItem.init(title: "选择", style: .plain, target: self, action: #selector(MatchEngineerViewController.chooseItemAction))
        self.chooseItem.tintColor = UIColor.RGBS(s: 33)
        self.navigationItem.rightBarButtonItems = [chooseItem,mapItem]
        
        self.tableView.register(UINib.init(nibName: "HomeEngineerCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeEngineerCell")
        //添加刷新
        self.addRefresh()
        
        //加载数据
        self.loadData()
    }
    
    //返回到首页
    @objc func backClick() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //点击全选按钮
    @IBAction func selectAction() {
        self.selectedArray.removeAll()
        if !self.selectedBtn.isSelected{
            for subJson in self.engListArray {
                self.selectedArray.append(subJson["member_id"].stringValue)
            }
        }
        self.tableView.reloadData()
        self.selectedBtn.isSelected = !self.selectedBtn.isSelected
    }
    //提醒接单接口
    @IBAction func sureAction() {
        if self.selectedArray.count == 0{
            LYProgressHUD.showError("请至少选择一个工程师！")
            return
        }
        var params : [String : Any] = [:]
        params["id"] = self.bill_id
        params["member_ids"] = self.selectedArray.joined(separator: ",")
        NetTools.requestData(type: .post, urlString: MatchEngineerApi,parameters: params, succeed: { (resultDict, error) in
            LYProgressHUD.dismiss()
            LYAlertView.show("提醒成功", "已提醒工程师接单", "", "知道了", { 
                self.navigationController?.popToRootViewController(animated: true)
            })
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    @objc func mapItemAction() {
        let mapMatchVC = MapMatchEngineerViewController()
        mapMatchVC.engListArray = self.engListArray
        self.navigationController?.pushViewController(mapMatchVC, animated: true)
    }
    
    //取消选择以及开始选择
    @objc func chooseItemAction() {
        self.selectedBtn.isSelected = false
        self.selectedArray.removeAll()
        if self.topView.isHidden{
            self.topView.isHidden = false
            self.topViewH.constant = 50
            self.sureBtn.isHidden = false
            self.sureBtnH.constant = 50
            self.chooseItem.title = "取消"
        }else{
            self.topView.isHidden = true
            self.topViewH.constant = 0
            self.sureBtn.isHidden = true
            self.sureBtnH.constant = 0
            self.chooseItem.title = "选择"
        }
        self.tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension MatchEngineerViewController : UITableViewDelegate,UITableViewDataSource{
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
    //停止刷新
    func stopRefresh() {
        LYProgressHUD.dismiss()
        self.tableView.es.stopLoadingMore()
        self.tableView.es.stopPullToRefresh()
        
        if self.engListArray.count > 0{
            self.hideEmptyView()
            self.tableView.reloadData()
        }else{
            self.showEmptyView()
        }
    }
    //加载数据
    func loadData() {
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        params["id"] = bill_id
        NetTools.requestData(type: .post, urlString: MatchEngineerListApi,parameters: params, succeed: { (resultJson, error) in
            
            self.engListArray = resultJson.arrayValue
            
            self.stopRefresh()
            //判断是否可以加载更多
            if resultJson.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.engListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeEngineerCell", for: indexPath) as! HomeEngineerCell
        if self.engListArray.count > indexPath.row{
            cell.jsonModel = self.engListArray[indexPath.row]
            cell.selectedCellBlock = {() in
                if self.selectedArray.contains(self.engListArray[indexPath.row]["member_id"].stringValue){
                    self.selectedArray.remove(at: self.selectedArray.index(of: self.engListArray[indexPath.row]["member_id"].stringValue)!)
                }else{
                    self.selectedArray.append(self.engListArray[indexPath.row]["member_id"].stringValue)
                }
                self.tableView.reloadData()
            }
            if self.topView.isHidden{
                cell.selectedBtn.isHidden = true
            }else{
                cell.selectedBtn.isHidden = false
                if self.selectedArray.contains(self.engListArray[indexPath.row]["member_id"].stringValue){
                    cell.selectedBtn.setImage(#imageLiteral(resourceName: "btn_checkbox_s"), for: .normal)
                }else{
                    cell.selectedBtn.setImage(#imageLiteral(resourceName: "btn_checkbox_n"), for: .normal)
                }
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 133
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.engListArray.count > indexPath.row{
            let jsonModel = self.engListArray[indexPath.row]
            let engineerDetailVC = EngineerDetailViewController()
            engineerDetailVC.member_id = jsonModel["member_id"].stringValue
            self.navigationController?.pushViewController(engineerDetailVC, animated: true)
        }
    }
}
