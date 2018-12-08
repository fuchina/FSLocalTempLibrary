//
//  FSKitDuty.m
//  myhome
//
//  Created by FudonFuchina on 2017/6/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSKitDuty.h"
#import <ifaddrs.h>
#include <net/if.h>
#import <FSRuntime.h>
#import <FSDate.h>

@implementation FSKitDuty

+ (NSArray *)maopaoArray:(NSArray *)array{
    if (array.count == 0) {
        return nil;
    }
    
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    for (int x = 0; x < mArray.count - 1; x ++) {
        for (int y = 0; y < mArray.count - 1 - x; y ++) {
            double first = [mArray[y] floatValue];
            double second = [mArray[y + 1] floatValue];
            if (first < second) {
                double temp = first;
                [mArray replaceObjectAtIndex:y withObject:@(second).stringValue];
                [mArray replaceObjectAtIndex:y+1 withObject:@(temp).stringValue];
            }
        }
    }
    return mArray;
}

+ (BOOL)noNet{
    return ([self networkStatus] == NotReachable);
}

+ (NetworkStatus)networkStatus{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [r currentReachabilityStatus];
    return status;
}

+ (void)letModelEveryPropertyDefaultValue:(NSString *)value object:(id)object{
    if (value == nil || object == nil) {
        return;
    }
    NSArray *ps = [FSRuntime propertiesForClass:[object class]];
    for (NSString *p in ps) {
        [FSRuntime setValue:value forPropertyName:p ofObject:object];
    }
}

+ (BOOL)isWiFiEnabled{
    NSCountedSet * cset = [[NSCountedSet alloc] init];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

+ (NSString *)time:(NSString *)seconds formatter:(NSString *)formatter{
    NSTimeInterval tm = [seconds doubleValue];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:tm];
    NSString *time = [FSDate stringWithDate:date formatter:formatter];
    return time;
}

+ (NSString *)dayMonthYearForNumber:(CGFloat)number{
    if (number > 365) {
        return [[NSString alloc] initWithFormat:@"%.2f%@",number / 365.0,NSLocalizedString(@"year", nil)];
    }else if (number > 30){
        return [[NSString alloc] initWithFormat:@"%.2f%@",number / 30,NSLocalizedString(@"month", nil)];
    }else{
        return [[NSString alloc] initWithFormat:@"%.2f%@",number,NSLocalizedString(@"day", nil)];
    }
}

NSComparisonResult _fs_highAccuracy_compare(NSString *a,NSString *b){
    if (!_fs_isPureFloat(a)) {
        a = @"0";
    }
    if (!_fs_isPureFloat(b)) {
        b = @"0";
    }
    NSDecimalNumber *addendNumber = [NSDecimalNumber decimalNumberWithString:a];
    NSDecimalNumber *augendNumber = [NSDecimalNumber decimalNumberWithString:b];
    NSComparisonResult result = [addendNumber compare:augendNumber];
    return result;
}

// 排序
+ (NSArray<FSBestAccountModel *> *)sortForResults:(NSMutableArray<FSBestAccountModel *> *)list{
    [list sortUsingComparator:^NSComparisonResult(FSBestAccountModel *obj1, FSBestAccountModel *obj2) {
        if (obj1.selectedTime > obj2.selectedTime) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
    return list;
}

@end
