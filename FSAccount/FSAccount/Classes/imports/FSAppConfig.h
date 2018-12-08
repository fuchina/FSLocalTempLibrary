//
//  FSAppConfig.h
//  myhome
//
//  Created by Fudongdong on 2017/12/23.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSAppConfigModel.h"
#import "AppConfiger.h"

@interface FSAppConfig : NSObject   // 只可以存字符串或NSNumber

+ (NSString *)saveObject:(NSString *)value forKey:(NSString *)key;
+ (FSAppConfigModel *)modelForKey:(NSString *)key;
+ (NSString *)objectForKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;

@end
