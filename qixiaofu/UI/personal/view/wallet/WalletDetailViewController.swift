//
//  WalletDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/31.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class WalletDetailViewController: BaseViewController {
    class func spwan() -> WalletDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! WalletDetailViewController
    }

    
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyImgV: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    fileprivate lazy var dataArray : Array<JSON> = {
        let dataArray = Array<JSON>()
        return dataArray
    }()
    fileprivate var time = "0"
    fileprivate var timeType = "0"
    fileprivate var desc = "0"
    fileprivate var curpage : Int = 1
    
    fileprivate let descArray = ["全部","发单","完成订单","取消订单","撤消发单","购买备件","取消商城订单","退货","充值","提现","置顶","调价"]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefresh()
        
        self.loadData()
        
        self.navigationItem.title = "账户余额明细"
        self.tableView.register(UINib.init(nibName: "WalletDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "WalletDetailCell")
        self.collectionView.register(UINib.init(nibName: "FiltrateCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FiltrateCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    
//加载数据
    func loadData() {
        var params : [String : Any] = [:]
        params["type"] = "1"//  	【1，钱包余额明细】【2，众筹余额明细】【不传为显示所有】
        params["curpage"] = self.curpage
        //时间区间
        params["time"] = self.time
        //时间区间类别
        params["time_type"] = self.timeType
        //交易类别
        params["desc"] = self.desc
//LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: WalletDetailApi, parameters: params, succeed: { (result, msg) in
            self.curpage == 1 ? self.tableView.es.stopPullToRefresh() : self.tableView.es.stopLoadingMore()
            LYProgressHUD.dismiss()
            
            if self.curpage == 1{
                self.dataArray.removeAll()
            }
            //添加数据
            for subJson in result.arrayValue{
                self.dataArray.append(subJson)
            }
            
            //判断是否可以加载更多
            if result.arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            //是否为空
            self.emptyImgV.isHidden = self.dataArray.count > 0
            
            self.tableView.reloadData()
            
        }) { (error) in
            self.curpage == 1 ? self.tableView.es.stopPullToRefresh() : self.tableView.es.stopLoadingMore()
            LYProgressHUD.showError(error!)
        }
        
    }

    @IBAction func dateSort() {
        let lyDatePicker = LYDatePicker.init(component: 3)
        //选择时间
        lyDatePicker.ly_datepickerWithComponent = {(date,year,month,day,component) -> Void in
            self.timeType = "\(component)"
            var dateStr = ""
            var dateTimestamp = ""
            if component == 1{
                dateStr = "\(year)"
                dateTimestamp = Date.dateFromDateString(format: "yyyy", dateString: dateStr).phpTimestamp()
            }else if component == 2{
                dateStr = "\(year)\(month)"
                dateTimestamp = Date.dateFromDateString(format: "yyyyMM", dateString: dateStr).phpTimestamp()
            }else{
                dateStr = "\(year)\(month)\(day)"
                dateTimestamp = Date.dateFromDateString(format: "yyyyMMdd", dateString: dateStr).phpTimestamp()
            }
            self.time = dateTimestamp
            
            self.curpage = 1
            self.loadData()
        }
        lyDatePicker.showWithTimeType()
    }

    @IBAction func typeSort() {
        self.collectionView.isHidden = !self.collectionView.isHidden
    }
}


extension WalletDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletDetailCell", for: indexPath) as! WalletDetailCell
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            cell.subJson = subJson
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            let size = subJson["desc"].stringValue.sizeFit(width: kScreenW - 16, height: CGFloat(MAXFLOAT), fontSize: 14.0)
            if size.height > 21{
                return size.height + 50
            }
        }
        return 72
    }
}

extension WalletDetailViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.descArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltrateCell", for: indexPath) as! FiltrateCell
        cell.bg_imgV.image = #imageLiteral(resourceName: "textboder_bg_gray")
        if descArray.count > indexPath.row{
            cell.titleLbl.text = descArray[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if descArray.count > indexPath.row{
            if (indexPath.row == self.descArray.count - 1){
                self.desc = "\(indexPath.row + 1)"
            }else{
                self.desc = "\(indexPath.row)"
            }
            self.collectionView.isHidden = true
            self.typeBtn.setTitle(self.descArray[indexPath.row], for: .normal)
            
            self.curpage = 1
            self.loadData()
        }
    }
    
    
}

extension WalletDetailViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW - 40)/3, height:30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    
}
