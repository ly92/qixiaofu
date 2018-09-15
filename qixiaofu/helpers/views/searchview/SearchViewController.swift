//
//  SearchViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {
    class func spwan() -> SearchViewController{
        return self.loadFromStoryBoard(storyBoard: "Main") as! SearchViewController
    }
    
    typealias SearchViewControllerBlock = (String) -> ()
    var searchWithSearchWordBlock : SearchViewControllerBlock?
    
    
    @IBOutlet weak var subControl: UIControl!
    
    @IBOutlet weak var hotCollectionView: UICollectionView!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    
    @IBOutlet weak var hotView: UIView!
    @IBOutlet weak var hotViewH: NSLayoutConstraint!
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historyViewH: NSLayoutConstraint!
    
    let searchBar : UISearchBar = UISearchBar()
    
    fileprivate lazy var hotArray : Array<String> = {
        let hotArray = ["IBM","HP","X86","LINUX","UNIX","监控设备"]
        return hotArray
    }()
    fileprivate lazy var historyArray : Array<String> = {
        let historyArray = Array<String>()
        return historyArray
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotCollectionView.register(UINib.init(nibName: "SearchWordCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SearchWordCell")
        self.historyCollectionView.register(UINib.init(nibName: "SearchWordCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SearchWordCell")
        
        self.historyArray = LocalData.getSearchHistoryArray()
        
        self.subControl.addTarget(self, action: #selector(SearchViewController.endSearchEdit), for: .touchDown)
        
        self.setUpSearchNavView()
        self.setUpSubViews()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil

    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func callBackBlock(block : SearchViewControllerBlock?) {
        self.searchWithSearchWordBlock = block
    }
    
    @IBAction func deleteSearchHistory() {
        LocalData.removeSearchHistory()
        self.historyArray.removeAll()
        self.setUpSubViews()
        self.historyCollectionView.reloadData()
    }
    
}

extension SearchViewController{
    func setUpSearchNavView() {
        searchBar.placeholder = "请输入品牌型号、地点等搜索"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW-120, height: 44))
        searchBar.frame = view.bounds
        view.addSubview(searchBar)
        self.navigationItem.titleView = view
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消" , target: self, action: #selector(SearchViewController.backWithSearchWord))
        guard let searchBarTF = searchBar.value(forKey: "searchField") as? UITextField else {
            return
        }
        searchBarTF.font = UIFont.systemFont(ofSize: 15.0)
    }
    
    @objc func backWithSearchWord() {
        self.endSearchEdit()
        if (self.searchWithSearchWordBlock != nil){
            self.searchWithSearchWordBlock!("")
        }
        self.dismiss(animated: false, completion: nil)
//        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func endSearchEdit() {
        searchBar.resignFirstResponder()
    }
    
    func setUpSubViews() {
        //推荐搜索viwe
        if self.hotArray.count == 0{
            self.hotView.isHidden = true
            self.hotViewH.constant = 0
        }else if self.hotArray.count % 2 == 0{
            self.hotView.isHidden = false
            self.hotViewH.constant = CGFloat(self.hotArray.count / 2 * 27 + 60)
        }else{
            self.hotView.isHidden = false
            self.hotViewH.constant = CGFloat(self.hotArray.count / 2 * 27 + 27 + 60)
        }
        
        //历史搜索view
        if self.historyArray.count == 0{
            self.historyView.isHidden = true
            self.historyViewH.constant = 0
        }else if self.historyArray.count % 2 == 0{
            self.historyView.isHidden = false
            self.historyViewH.constant = CGFloat(self.historyArray.count / 2 * 27 + 60)
        }else{
            self.historyView.isHidden = false
            self.historyViewH.constant = CGFloat(self.historyArray.count / 2 * 27 + 27 + 60)
        }
        
    }
    
}

//MARK: - UISearchBarDelegate
extension SearchViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        if !(searchBar.text?.isEmpty)!{
            LocalData.saveSearchHistory(searchWord: searchBar.text!)
        }
        self.endSearchEdit()
        if (self.searchWithSearchWordBlock != nil){
            self.searchWithSearchWordBlock!(searchBar.text!)
        }
        self.dismiss(animated: false, completion: nil)
//        self.navigationController?.popViewController(animated: false)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension SearchViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hotCollectionView{
            return self.hotArray.count
        }else if collectionView == historyCollectionView{
            return self.historyArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchWordCell", for: indexPath) as! SearchWordCell
        
        if collectionView == hotCollectionView{
            if self.hotArray.count > indexPath.row{
                cell.titleLbl.text = self.hotArray[indexPath.row]
            }
        }else{
            if self.historyArray.count > indexPath.row{
                cell.titleLbl.text = self.historyArray[indexPath.row]
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        var searchWord = ""
        
        if collectionView == hotCollectionView{
            if self.hotArray.count > indexPath.row{
                searchWord = self.hotArray[indexPath.row]
            }
        }else{
            if self.historyArray.count > indexPath.row{
                searchWord = self.historyArray[indexPath.row]
            }
        }
        self.endSearchEdit()
        LocalData.saveSearchHistory(searchWord: searchWord)
        if (self.searchWithSearchWordBlock != nil){
            self.searchWithSearchWordBlock!(searchWord)
        }
        self.dismiss(animated: false, completion: nil)
//        self.navigationController?.popViewController(animated: false)
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW - 55)/2.0, height:25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 5,bottom: 5,right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
