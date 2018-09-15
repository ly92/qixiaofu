# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

target 'qixiaofu' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
#    pod 'MonkeyKing'#分享组件
    #pod 'SnapKit' #自动布局 http://www.hangge.com/blog/cache/detail_1097.html
    pod 'Kingfisher' #图片处理 http://www.jianshu.com/p/fa2624ac1959
    pod 'Alamofire'#网络请求
    pod 'AlamofireObjectMapper'
    #pod 'XCGLogger' #日志打印 http://blog.csdn.net/u014484863/article/details/50636468
    # pod 'RxSwift' #http://www.jianshu.com/p/d57ff2b3e0d4
    #pod 'RxCocoa'
    pod 'SwiftyJSON'#字典转模型 http://www.hangge.com/blog/cache/detail_968.html
    #pod 'PNChart’ #带动画效果的图表控件库
    pod 'ESPullToRefresh'#列表刷新
#    pod 'ImagePicker'#图片选择器

    #高德地图
#    pod 'AMap3DMap-NO-IDFA'#3D地图
#    pod 'AMapSearch-NO-IDFA'#搜索
#    pod 'AMapLocation-NO-IDFA'#定位
#    pod 'AMapNavi-NO-IDFA'#导航

    #百度地图
    pod 'BaiduMapKit', '~> 4.1.0'
    
    #pod 'LYTools'
    
    #友盟分享
    # U-Share SDK UI模块（分享面板，建议添加）
    pod 'UMengUShare/UI'
    # 集成微信(精简版0.2M)
    pod 'UMengUShare/Social/ReducedWeChat'
    # 集成QQ/QZone/TIM(精简版0.5M)
    pod 'UMengUShare/Social/ReducedQQ'
    # 集成新浪微博(精简版1M)
    pod 'UMengUShare/Social/ReducedSina'
    # 集成邮件
    pod 'UMengUShare/Social/Email'
    # 集成短信
    pod 'UMengUShare/Social/SMS'
    
    #极光推送
    pod 'JPush'
    #约束
    pod 'SnapKit'
    #下载
    pod 'ZFDownload'
    
    #腾讯bugly，app异常检测
    pod 'Bugly'
    
    target 'qixiaofuTests' do
        inherit! :search_paths
        # Pods for testing
    end
    
    target 'qixiaofuUITests' do
        inherit! :search_paths
        # Pods for testing
    end
    
end
