//
//  TestCategoryViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/10.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestCategoryViewController: BaseViewController {
    class func spwan() -> TestCategoryViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! TestCategoryViewController
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var testServiceArray : JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.testServiceData()
        self.navigationItem.title = "七小服代测"
        self.collectionView.register(UINib.init(nibName: "HomeCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        self.collectionView.contentInset = UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //代测分类列表
    func testServiceData() {
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: TestServiceApi, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.testServiceArray = resultJson
            self.collectionView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取分类错误")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension TestCategoryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.testServiceArray.arrayValue.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        if self.testServiceArray.arrayValue.count > indexPath.row{
            let json = self.testServiceArray.arrayValue[indexPath.row]
            item.titleLbl.text = json["systematic_name"].stringValue
            item.iconImgV.setImageUrlStr(json["systematic_photo"].stringValue)
        }else{
            item.titleLbl.text = "定制测试"
            item.iconImgV.image = #imageLiteral(resourceName: "custom_test_icon")
        }
        return item
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w : CGFloat = 0.0
        if kScreenW >= 414{
            w = (kScreenW - 10) / 4.0
        }else{
            w = (kScreenW - 10) / 3.0
        }
        return CGSize.init(width: w, height: w + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NetTools.qxfClickCount("9")
        if self.testServiceArray.arrayValue.count > indexPath.row{
            let json = self.testServiceArray.arrayValue[indexPath.row]
            let addTestVC = AddTestViewController.spwan()
            addTestVC.firstSecId = json["id"].stringValue
            addTestVC.testServiceArray = self.testServiceArray
            self.navigationController?.pushViewController(addTestVC, animated: true)
        }else{
            esmobChat(self, "kefu1", 1)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}

