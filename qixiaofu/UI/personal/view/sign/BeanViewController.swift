//
//  BeanViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/1.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class BeanViewController: BaseViewController {
    class func spwan() -> BeanViewController{
        return self.loadFromStoryBoard(storyBoard: "Personal") as! BeanViewController
    }
    
    var userId = ""
    
    @IBOutlet weak var conLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ruleView: UIView!
    @IBOutlet weak var ruleLbl: UILabel!
    @IBOutlet weak var ruleSubViewH: NSLayoutConstraint!
    @IBOutlet weak var emptyImgV: UIView!
    @IBOutlet weak var backBtnTopDis: NSLayoutConstraint!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var payCodeView: UIView!
    @IBOutlet weak var payCodeImgV: UIImageView!
    
    
    fileprivate var curpage : NSInteger = 1
    fileprivate lazy var dataArray : NSMutableArray = {
        let dataArray = NSMutableArray()
        return dataArray
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的服豆"
        // Do any additional setup after loading the view.
        
        self.tableView.register(UINib.init(nibName: "BeanCell", bundle: Bundle.main), forCellReuseIdentifier: "BeanCell")
        self.ruleView.addTapActionBlock {
            self.ruleAction()
        }
        self.ruleSubViewH.constant = 0
        self.subView.layer.cornerRadius = 8
        self.loadConList()
        self.preparePayAscii()
        //添加刷新
        self.addRefresh()
        if iphoneType() == "iPhone X"{
            self.backBtnTopDis.constant = 35
        }
        
    }
    
    func addRefresh() {
        self.tableView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
            self?.loadConList()
        }
        self.tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.curpage += 1
            self?.loadConList()
        }
    }
    
    func loadConList() {
        //
        var params : [String : Any] = [:]
        params["curpage"] = self.curpage
        
        NetTools.requestData(type: .post, urlString: KCouponListApi, parameters: params, succeed: { (result, msg) in

            //停止刷新
            if self.curpage == 1{
                self.dataArray.removeAllObjects()
                self.tableView.es.stopPullToRefresh()
            }else{
                self.tableView.es.stopLoadingMore()
            }
            
            //判断是否可以加载更多
            if result["list"].arrayValue.count < 10{
                self.tableView.es.noticeNoMoreData()
            }else{
                self.tableView.es.resetNoMoreData()
            }
            
            self.conLbl.text = String.init(format: "%.0f", result["all_fudou"].stringValue.floatValue)
            for subJson in result["list"].arrayValue{
                self.dataArray.add(subJson)
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
    
    func preparePayAscii() {

        if self.userId.isEmpty{
            return
        }

        let str = self.userId + ",2"
        let data = str.data(using: String.Encoding.ascii)
        guard let filter = CIFilter.init(name: "CICode128BarcodeGenerator") else{
            return
        }
        filter.setValue(data, forKey: "inputMessage")
        //生成条形码
        guard let ciImg = filter.outputImage else {
            return
        }
        //4.调整清晰度
        //创建Transform
        let scale = (kScreenW - 40) / ciImg.extent.width
        let transform = CGAffineTransform.init(scaleX: scale, y: 90)
        //放大图片
        let bigImg = ciImg.transformed(by: transform)
        self.payCodeImgV.image = UIImage.init(ciImage: bigImg)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func rechargeAction() {
        //充值
        let rechargeVC = RechargeViewController.spwan()
        rechargeVC.vcType = 3
        self.navigationController?.pushViewController(rechargeVC, animated: true)
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ruleAction() {
        self.ruleView.isHidden = !self.ruleView.isHidden
        if self.ruleView.isHidden{
            self.ruleSubViewH.constant = 0
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.ruleSubViewH.constant = self.ruleLbl.resizeHeight() + 55
            })
        }
    }
    
    @IBAction func showPayCodeAction() {
        self.payCodeView.isHidden = false
    }
    
    @IBAction func showTableAction() {
        self.payCodeView.isHidden = true
    }
    
}

extension BeanViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeanCell", for: indexPath) as! BeanCell
        if self.dataArray.count > indexPath.row{
            let jsonModel = self.dataArray[indexPath.row] as! JSON
            cell.subJson = jsonModel
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

