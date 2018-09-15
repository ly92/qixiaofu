//
//  MoreFunctionViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/15.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MoreFunctionViewController: BaseViewController {
    
    //
    fileprivate var collectionView : UICollectionView!
    fileprivate var resultJson : JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "更多"
        //配置collectionView
        self.setUpCollectionView()
//        self.collectionView.backgroundColor = BG_Color
        
        self.loadData()
    }
    
    //配置collectionView
    func setUpCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        let w = (kScreenW - 20) / 4 - 10
        flowLayout.itemSize = CGSize.init(width: w, height: w + 10)
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.headerReferenceSize = CGSize.init(width: kScreenW, height: 40)
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH-64), collectionViewLayout: flowLayout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        self.collectionView.register(UINib.init(nibName: "HomeCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MoreFunctionCollectionViewCell")
        self.collectionView.register(MoreFuncReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MoreFuncReusableView")
        self.collectionView.backgroundColor = UIColor.white
    }
    
    //加载数据
    func loadData() {
        NetTools.requestData(type: .post, urlString: HomeMoreApi, succeed: { (resultJson, msg) in
            self.resultJson = resultJson
            self.collectionView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络请求错误！")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension MoreFunctionViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.resultJson.arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.resultJson.arrayValue.count > section{
           return self.resultJson.arrayValue[section]["data"].arrayValue.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item : HomeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreFunctionCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        if self.resultJson.arrayValue.count > indexPath.section{
            if self.resultJson.arrayValue[indexPath.section]["data"].arrayValue.count > indexPath.row{
                let json = self.resultJson.arrayValue[indexPath.section]["data"].arrayValue[indexPath.row]
                item.titleLbl.text = json["list_name"].stringValue
                item.iconImgV.setImageUrlStr(json["list_img"].stringValue)
                if LocalData.ContentPointNum(num: json["sort_type"].stringValue.intValue){
                    item.redPointView.isHidden = false
                }else{
                    item.redPointView.isHidden = true
                }
            }
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if self.resultJson.arrayValue.count > indexPath.section{
            if self.resultJson.arrayValue[indexPath.section]["data"].arrayValue.count > indexPath.row{
                let subJson = self.resultJson.arrayValue[indexPath.section]["data"].arrayValue[indexPath.row]
                let list_type = subJson["list_type"].stringValue//1:本地 2:web
                if list_type.intValue == 2{
                    let webVC = BaseWebViewController.spwan()
                    webVC.urlStr = subJson["sort_url"].stringValue
                    webVC.titleStr = subJson["list_name"].stringValue
                    self.navigationController?.pushViewController(webVC, animated: true)
                }else{
                    let sort_type = subJson["sort_type"].stringValue
                    if sort_type.isEmpty{
                        return
                    }
                    functionSkipAction(type: sort_type, controller: self)
//                    switch sort_type.intValue {
//                    case 1:
//                        //去发单
//                        UserViewModel.haveTrueName(parentVC: self, {
//                            NetTools.qxfClickCount("1")
//                            let sendTaskVC = SendTaskViewController.spwan()
//                            self.navigationController?.pushViewController(sendTaskVC, animated: true)
//                        })
//                    case 2:
//                        //去接单
//                        let taskVC = TaskListViewController.spwan()
//                        taskVC.isHomeAllTaskList = true
//                        self.navigationController?.pushViewController(taskVC, animated: true)
//                    case 3:
//                        //钱包
//                        let moneyVC = MyMoneyViewController()
//                        self.navigationController?.pushViewController(moneyVC, animated: true)
////                        let walletVC = WalletViewController.spwan()
////                        walletVC.beanNum = LocalData.getBeanCount().intValue
////                        walletVC.userId = LocalData.getNotMd5UserId()
////                        self.navigationController?.pushViewController(walletVC, animated: true)
//                    case 4:
//                        //签到
//                        let signVC = SignInViewController.spwan()
//                        self.navigationController?.pushViewController(signVC, animated: true)
//                    case 5:
//                        //我的发单
//                        let mySendVC = MySendOrderListViewController.spwan()
//                        mySendVC.titleArray = ["报名中","已接单","已完成","已取消","已失效"]
//                        mySendVC.stateArray = [1,2,3,5,4]
//                        self.navigationController?.pushViewController(mySendVC, animated: true)
//                    case 6:
//                        //我的接单
//                        let myReceiveVC = MySendOrderListViewController.spwan()
//                        myReceiveVC.titleArray = ["报名中","已接单","已完成","已取消","调价中"]
//                        myReceiveVC.stateArray = [1,2,3,5,6]
//                        myReceiveVC.isMyReceive = true
//                        self.navigationController?.pushViewController(myReceiveVC, animated: true)
//                    case 7:
//                        //企业采购
//                        print("企业采购")
//                    case 8:
//                        //更多
//                        print("更多")
//                    case 9:
//                        //公告
//                        let noticeListVC = NoticeListViewController()
//                        self.navigationController?.pushViewController(noticeListVC, animated: true)
//                    case 10 :
//                        //领券中心
//                        let couponVC = CouponListViewController()
//                        self.navigationController?.pushViewController(couponVC, animated: true)
//                    default:
//                        //
//                        LYProgressHUD.showError("当前版本不支持，快去App Store下载最新版本")
//                    }
                }
            }
        }
        
        
    }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MoreFuncReusableView", for: indexPath) as! MoreFuncReusableView
        if self.resultJson.arrayValue[indexPath.section]["data"].arrayValue.count > indexPath.row{
            reusableView.titleLbl.text = self.resultJson.arrayValue[indexPath.section]["lable"].stringValue
            
        }
        
        return reusableView
    }
    
    
    
}

class MoreFuncReusableView : UICollectionReusableView{
    fileprivate let lineView = UIView()
    let titleLbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        let lineView = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 8))
        lineView.backgroundColor = BG_Color
        self.addSubview(lineView)
        
        self.titleLbl.frame = CGRect.init(x: 15, y: 15, width: kScreenW-30, height: 21)
        self.addSubview(titleLbl)
        self.titleLbl.textColor = Text_Color
        self.titleLbl.font = UIFont.systemFont(ofSize: 14.0)
        self.backgroundColor = UIColor.white
    }
    
}







