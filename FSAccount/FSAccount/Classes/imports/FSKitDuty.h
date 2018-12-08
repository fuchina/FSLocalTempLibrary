//
//  FSKitDuty.h
//  myhome
//
//  Created by FudonFuchina on 2017/6/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//


/*
    注意：这个类的方法都会在FSKit中,等发布后这些方法可以去掉，用FSKit调用
 */

#import <UIKit/UIKit.h>
#import <FSKit.h>
#import "Reachability.h"
#import "FSBestAccountModel.h"

@interface FSKitDuty : NSObject

+ (NSArray *)maopaoArray:(NSArray *)array;

+ (BOOL)noNet;
+ (NetworkStatus)networkStatus;

+ (void)letModelEveryPropertyDefaultValue:(NSString *)value object:(id)object;

// 判断手机是否打开WIFI功能
+ (BOOL)isWiFiEnabled;

// 时间秒数转  2018-10-10 10：10：10
+ (NSString *)time:(NSString *)seconds formatter:(NSString *)formatter;

+ (NSString *)dayMonthYearForNumber:(CGFloat)number;

NSComparisonResult _fs_highAccuracy_compare(NSString *a,NSString *b);

+ (NSArray*)sortForResults:(NSMutableArray *)list;

@end
