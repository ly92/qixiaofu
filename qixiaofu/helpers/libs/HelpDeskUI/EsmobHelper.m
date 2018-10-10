//
//  EsmobHelper.m
//  qixiaofu
//
//  Created by ly on 2017/11/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

#import "EsmobHelper.h"
#import "SDImageCache.h"
#import <HelpDesk/HelpDesk.h>

@implementation EsmobHelper

@end


@implementation HEmojiPackage
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _packageId = [dictionary valueForKey:@"id"];
        _packageName = [dictionary valueForKey:@"packageName"];
        _emojiNum = [[dictionary valueForKey:@"fileNum"] integerValue];
        _tenantId = [[dictionary valueForKey:@"tenantId"] stringValue];
    }
    return self;
}

@end

@implementation HEmoji

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _emojiName = [dictionary valueForKey:@"fileName"];
        _originUrl = [dictionary valueForKey:@"originUrl"];
        _thumbnailUrl = [dictionary valueForKey:@"thumbnailUrl"];
        _originMediaId = [dictionary valueForKey:@"originMediaId"];
        _thumbnailMediaId = [dictionary valueForKey:@"thumbnailMediaId"];
    }
    return self;
}

- (NSString *)originUrl {
    NSString *orUrl = [[HDClient sharedClient].kefuRestServer stringByAppendingString:_originUrl];
    return orUrl;
}

- (NSString *)thumbnailUrl {
    NSString *thUrl = [[HDClient sharedClient].kefuRestServer stringByAppendingString:_thumbnailUrl];
    return thUrl;
}

- (NSString *)originLocalPath {
    return [[SDImageCache sharedImageCache] defaultCachePathForKey:_originMediaId];
}

- (NSString *)thumbnailLocalPath {
    return [[SDImageCache sharedImageCache] defaultCachePathForKey:_thumbnailMediaId];
}

//- (HDEmotionType)emotionType {
//    return HDEmotionGif;
//}

@end

