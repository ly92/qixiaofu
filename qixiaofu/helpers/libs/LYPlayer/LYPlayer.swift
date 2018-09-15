//
//  LYPlayer.swift
//  LYPlayer
//
//  Created by ly on 2017/10/18.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class LYPlayer: NSObject {
    // 下载文件的总文件夹
    static let BASE = "/ZFDownLoad"
    // 完整文件路径
    static let TARGET = "/CacheList"
    // 临时文件夹名称
    static let TEMP = "/Temp"
    // 缓存主目录
    static let CACHES_DIRECTORY = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
    // 临时文件夹的路径
    class var TEMP_FOLDER : String {
        get{
            return CACHES_DIRECTORY + BASE + TEMP
        }
    }
    // 临时文件的路径
    class func TEMP_PATH(_ name : String) -> String {
        return self.createFolder(TEMP_FOLDER) + name
    }
    
    // 下载文件夹路径
    class var FILE_FOLDER : String{
        get{
            return CACHES_DIRECTORY + BASE + TARGET
        }
    }
    // 下载文件的路径
    class func FILE_PATH(_ name : String) -> String {
        return self.createFolder(FILE_FOLDER) + name
    }
    
    // 文件信息的Plist路径
    class var PLIST_PATH : String {
        return CACHES_DIRECTORY + BASE + "/FinishedPlist.plist"
    }
    
    //创建文件夹
    class func createFolder(_ filePath : String) -> String {
        let fm = FileManager.default
        if !fm.fileExists(atPath: filePath){
            do{
                try fm.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                print(error)
            }
        }
        return filePath + "/"
    }
    
    /** 将文件大小转化成M单位或者B单位 */
    class func getFileSizeString(_ size : String) -> String {
        if size.floatValue >= 1024 * 1024{
            //大于1M，则转化成M单位的字符串
            return String.init(format: "%.2fM", size.floatValue/1024.0/1024.0)
        }else if size.floatValue >= 1024{
            //不到1M,但是超过了1KB，则转化成KB单位
            return String.init(format: "%.2fK", size.floatValue/1024.0)
        }else{
            //剩下的都是小于1K的，则转化成B单位
            return String.init(format: "%.2fB", size.floatValue)
        }
    }
}


