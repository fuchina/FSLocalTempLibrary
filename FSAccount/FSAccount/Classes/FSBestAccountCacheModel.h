//
//  FSBestAccountCacheModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/5/30.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBestAccountCacheModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy)   NSString   *time;

@property (nonatomic,copy)   NSString   *be;    // 属性，如收入、成本
@property (nonatomic,copy)   NSString   *km;    // 科目，如现金（流动资产属性）
@property (nonatomic,copy)   NSString   *yr;    // 年，如2018
@property (nonatomic,copy)   NSString   *mn;    // 月, 如05
@property (nonatomic,copy)   NSString   *p;     // 增加
@property (nonatomic,copy)   NSString   *m;     // 减少

+ (NSArray<NSString *> *)tableFields;

@end
