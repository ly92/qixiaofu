//
//  TestReportPictureViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/8/21.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestReportPictureViewController: BaseViewController {
    class func spwan() -> TestReportPictureViewController{
        return self.loadFromStoryBoard(storyBoard: "Globle") as! TestReportPictureViewController
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topViewTopDis: NSLayoutConstraint!
    @IBOutlet weak var orderLbl: UILabel!
    @IBOutlet weak var snLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    var testId = ""//扫码看测报
    
    var order_id = ""//订单详情看测报
    var goods_id = ""//订单详情看测报
    
    var reportJson = JSON()
    var pictureJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "测报&出库照片"
        
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 10, right: 10)
        self.collectionView.register(ReportCollectionViewCell.self, forCellWithReuseIdentifier: "ReportCollectionViewCell")
        self.collectionView.register(ReportReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ReportReusableView")
        
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //加载测报信息
    func loadData() {
        if self.testId.isEmpty{
            self.topViewTopDis.constant = -100
            let params : [String : Any] = ["goods_id" : self.goods_id,"order_id" : self.order_id]
            NetTools.requestData(type: .get, urlString: "api/index.php?act=member_order&op=show_testreport&store_id=1", parameters: params, succeed: { (result, msg) in
                self.reportJson = result["test_report"]
                self.pictureJson = result["info"]
                self.collectionView.reloadData()
            }) { (error) in
                LYProgressHUD.showError(error ?? "获取信息失败！")
            }
        }else{
            self.topViewTopDis.constant = 0
            let params : [String : Any] = ["id" : self.testId]
            NetTools.requestData(type: .get, urlString: "tp.php/Home/Public/sel", parameters: params, succeed: { (result, msg) in
                self.orderLbl.text = result["outbound_no"].stringValue
                self.snLbl.text = result["sn"].stringValue
                self.timeLbl.text = "测试时间" + Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: result["add_time"].stringValue)
                self.pictureJson = JSON([result["outbound_photo"]])
                self.reportJson = JSON([result["test_report"]])
                self.collectionView.reloadData()
            }) { (error) in
                LYProgressHUD.showError(error ?? "获取信息失败！")
            }
        }
    }
    
}


extension TestReportPictureViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.pictureJson.arrayValue.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return self.reportJson.arrayValue.count
        }
        if self.pictureJson.arrayValue.count > section - 1{
            if self.testId.isEmpty{
                let imgs = self.pictureJson.arrayValue[section-1]["sendGoodsImg"].arrayValue
                return imgs.count
            }else{
                let imgs = self.pictureJson.arrayValue[section-1].arrayValue
                return imgs.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item : ReportCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCollectionViewCell", for: indexPath) as! ReportCollectionViewCell
        if indexPath.section == 0{
            if self.reportJson.arrayValue.count > indexPath.row{
                let json = self.reportJson.arrayValue[indexPath.row]
                item.imgV.setImageUrlStr(json.stringValue)
            }
        }else{
            if self.pictureJson.arrayValue.count > indexPath.section-1{
                if self.testId.isEmpty{
                    let imgs = self.pictureJson.arrayValue[indexPath.section-1]["sendGoodsImg"].arrayValue
                    if imgs.count > indexPath.row{
                        item.imgV.setImageUrlStr(imgs[indexPath.row].stringValue)
                    }
                }else{
                    let imgs = self.pictureJson.arrayValue[indexPath.section-1].arrayValue
                    if imgs.count > indexPath.row{
                        item.imgV.setImageUrlStr(imgs[indexPath.row].stringValue)
                    }
                }
            }
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (kScreenW - 40)/3.0
        return CGSize.init(width: w, height: w)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ReportReusableView", for: indexPath) as! ReportReusableView
        if indexPath.section == 0{
            reusableView.titleLbl.text = "测试报告"
        }else{
            if self.pictureJson.arrayValue.count > indexPath.section-1{
                let subJson = self.pictureJson.arrayValue[indexPath.section-1]
                if self.testId.isEmpty{
                    reusableView.titleLbl.text = "出库实物照片(" + subJson["sn"].stringValue + ")"
                }else{
                    reusableView.titleLbl.text = "出库实物照片"
                }
            }
        }
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: kScreenW, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! ReportCollectionViewCell
        if cell.imgV.image != nil{
            let photoBrowseVC = LYPhotoBrowseViewController()
            photoBrowseVC.imgArray = [cell.imgV.image!]
            photoBrowseVC.showDeleteBtn = false
            UIApplication.shared.keyWindow?.addSubview(photoBrowseVC.view)
            photoBrowseVC.imgSingleTapBlock = {() in
                UIView.animate(withDuration: 0.25, animations: {
                    photoBrowseVC.view.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                }, completion: { (completion) in
                    photoBrowseVC.view.removeFromSuperview()
                })
            }
        }
    }
}


class ReportReusableView: UICollectionReusableView {
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
        self.titleLbl.frame = CGRect.init(x: 5, y: 15, width: kScreenW-30, height: 21)
        self.addSubview(titleLbl)
        self.titleLbl.textColor = Text_Color
        self.titleLbl.font = UIFont.systemFont(ofSize: 14.0)
        self.backgroundColor = UIColor.clear
    }
}

class ReportCollectionViewCell: UICollectionViewCell {
    let imgV = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        self.addSubview(self.imgV)
        self.imgV.snp.makeConstraints { (make) in
            make.top.left.bottom.trailing.equalTo(0)
//            make.top.left.equalTo(8)
//            make.bottom.trailing.equalTo(-8)
        }
        self.imgV.image = #imageLiteral(resourceName: "placeholder_icon")
    }
}

