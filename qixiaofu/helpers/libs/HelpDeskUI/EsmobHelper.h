//
//  EsmobHelper.h
//  qixiaofu
//
//  Created by ly on 2017/11/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EsmobHelper : NSObject

@end


@interface HEmojiPackage :NSObject
//表情包id
@property(nonatomic,copy) NSString *packageId;
//表情包名字
@property(nonatomic,copy) NSString *packageName;
//表情数
@property(nonatomic,assign) NSInteger emojiNum;
//tenantId
@property(nonatomic,copy) NSString *tenantId;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

@interface HEmoji :NSObject


@property(nonatomic,copy) NSString *emojiName;

@property(nonatomic,copy) NSString *originUrl;

@property(nonatomic,copy) NSString *originMediaId;

@property(nonatomic,copy) NSString *originLocalPath;

@property(nonatomic,copy) NSString *thumbnailUrl;

@property(nonatomic,copy) NSString *thumbnailMediaId;

@property(nonatomic,copy) NSString *thumbnailLocalPath;

//@property(nonatomic,assign) HDEmotionType emotionType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
