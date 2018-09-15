//
//  LocalDataOC.m
//  qixiaofu
//
//  Created by ly on 2017/8/18.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

#import "LocalDataOC.h"

@implementation LocalDataOC
//获取个人信息
+ (NSDictionary *)getChatUserInfo:(NSString *)key{
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults valueForKey:[NSString stringWithFormat:@"KEaseMobListKey%@",key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return dict;
}

// MARK: - 获取User phone
+ (NSString *)getUserPhone{
    
//    NSString *phone = [NSUserDefaults.standardUserDefaults valueForKey:[NSString stringWithFormat:@"KUserPhoneKey%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
     NSString *phone = [NSUserDefaults.standardUserDefaults valueForKey:[NSString stringWithFormat:@"KUserPhoneKey"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return phone;
}

@end
