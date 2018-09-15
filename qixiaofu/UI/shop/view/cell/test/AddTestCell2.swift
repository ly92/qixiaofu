//
//  AddTestCell2.swift
//  qixiaofu
//
//  Created by ly on 2018/2/2.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit

class AddTestCell2: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    var superVC = UIViewController()
    
    var reSetHeightBlock : ((CGFloat) -> Void)?
    var photoNumChangeBlock : ((Array<String>,Array<String>) -> Void)?
    
    var imgUrlArray : Array<String> = Array<String>()//元素为多个图片的url
    var imgDescArray : Array<String> = Array<String>(){
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func addSNAction() {
        //添加sn
        let addSnVc = AddTestSnViewController.spwan()
        addSnVc.addTestBlock = {(snStr,imgUrl) in
            self.imgDescArray.append(snStr)
            self.imgUrlArray.append(imgUrl)
            self.numChanged()
        }
        self.superVC.navigationController?.pushViewController(addSnVc, animated: true)
    }
 
    func numChanged() {
        if self.photoNumChangeBlock != nil{
            self.photoNumChangeBlock!(self.imgDescArray,self.imgUrlArray)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}


extension AddTestCell2 : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imgDescArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "")
        if cell == nil{
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "")
        }
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        cell?.textLabel?.textColor = UIColor.lightGray
        if self.imgDescArray.count > indexPath.row{
            cell?.textLabel?.text = self.imgDescArray[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if self.imgDescArray.count > indexPath.row{
            let addSnVc = AddTestSnViewController.spwan()
            addSnVc.snStr = self.imgDescArray[indexPath.row]
            let arr = self.imgUrlArray[indexPath.row].components(separatedBy: ",")
            addSnVc.imgUrlArray = arr
            addSnVc.addTestBlock = {(snStr,imgUrl) in
                self.imgUrlArray.remove(at: indexPath.row)
                self.imgDescArray.remove(at: indexPath.row)
                self.imgDescArray.insert(snStr, at: indexPath.row)
                self.imgUrlArray.insert(imgUrl, at: indexPath.row)
                self.numChanged()
            }
            addSnVc.deleteTestBlock = {() in
                self.imgUrlArray.remove(at: indexPath.row)
                self.imgDescArray.remove(at: indexPath.row)
            }
            self.superVC.navigationController?.pushViewController(addSnVc, animated: true)
        }
        
    }
    
}

