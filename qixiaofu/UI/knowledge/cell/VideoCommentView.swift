//
//  VideoCommentView.swift
//  qixiaofu
//
//  Created by ly on 2018/1/31.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


class VideoCommentView: UIView {

    var collectionView : UICollectionView!
    var resultJson = JSON()
    var selectArray : Array<JSON> = Array<JSON>()
    var lbl = UILabel()
    var btn = UIButton()
    var videoId = ""
    
    var commentSuccessBlock : (() -> Void)?
    
    init(frame: CGRect, videoId : String) {
        super.init(frame: frame)
        self.videoId = videoId
        self.backgroundColor = UIColor.RGBSA(s: 255, a: 1)
        self.setUpSubviews()
        self.loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        NetTools.requestData(type: .post, urlString: KVideoTagListApi, succeed: { (resultJson, msg) in
            self.resultJson = resultJson
            self.collectionView.reloadData()
            self.layoutIfNeeded()
        }) { (error) in
            
        }
    }
    
    
    func setUpSubviews() {
        self.lbl.text = "我来说两句"
        //        lbl.frame = CGRect.init(x: 10, y: 8, width: kScreenW-20, height: 21)
        self.addSubview(self.lbl)

        self.btn.clipsToBounds = true
        self.btn.setTitle("发表", for: .normal)
        self.btn.backgroundColor = UIColor.colorHex(hex: "ff7d47")
        self.addSubview(self.btn)
        self.btn.addTarget(self, action: #selector(VideoCommentView.commentAction), for: .touchUpInside)
        
        self.btn.layer.cornerRadius = 15
        
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 10, y: 40, width: kScreenW-20, height: 200), collectionViewLayout: layout)
        self.addSubview(self.collectionView!)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.register(UINib.init(nibName: "VideoCommentCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoCommentCell")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.h = self.collectionView.contentSize.height + 100
        
        
        self.btn.snp.makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-10)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        self.lbl.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.leading.trailing.equalTo(8)
            make.height.equalTo(21)
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.lbl.snp.bottom).offset(10)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(self.btn.snp.top).offset(-10)
        }
    }
    
    @objc func commentAction() {
        
        if self.selectArray.count == 0{
            LYProgressHUD.showError("请选择评论")
            return
        }
        var commentArr : Array<String> = Array<String>()
        for sub in self.selectArray{
            commentArr.append(sub["label_name"].stringValue)
        }
        var params : [String : Any] = [:]
        params["video_id"] = self.videoId
        params["comment_contents"] = commentArr.joined(separator: ",")
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: KVideoCommentApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            LYProgressHUD.showSuccess("评论成功！")
            if self.commentSuccessBlock != nil{
                self.commentSuccessBlock!()
            }
            self.removeFromSuperview()
        }, failure: { (error) in
            LYProgressHUD.showError(error ?? "请重试")
        })
    }
    
}

extension VideoCommentView : UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resultJson.arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCommentCell", for: indexPath) as! VideoCommentCell
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            cell.titleLbl.text = subJson["label_name"].stringValue
            cell.titleLbl.backgroundColor = UIColor.colorHex(hex: "999999")
            for sub in self.selectArray{
                if subJson["id"].stringValue.intValue == sub["id"].stringValue.intValue{
                    cell.titleLbl.backgroundColor = UIColor.colorHex(hex: "ff7d47")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            var index = -1
            for sub in self.selectArray{
                if subJson["id"].stringValue.intValue == sub["id"].stringValue.intValue{
                    index = self.selectArray.index(of: sub)!
                }
            }
            if index > -1{
                self.selectArray.remove(at: index)
            }else{
                self.selectArray.append(subJson)
            }
            
            self.collectionView.reloadData()
        }
    }
    
    
}

extension VideoCommentView : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            let str = subJson["label_name"].stringValue
            let size = str.sizeFit(width: CGFloat(MAXFLOAT), height: 21, fontSize: 14)
            return CGSize.init(width: size.width + 20, height: 30)
        }
        return CGSize.init(width: 0, height: 0)
    }
}


