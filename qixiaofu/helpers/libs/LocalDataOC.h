//
//  LocalDataOC.h
//  qixiaofu
//
//  Created by ly on 2017/8/18.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalDataOC : NSObject
//获取个人信息
+ (NSDictionary *)getChatUserInfo:(NSString *)key;
// MARK: - 获取User phone
+ (NSString *)getUserPhone;
    
@end
