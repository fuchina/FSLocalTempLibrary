//
//  FSBestSubjectModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestSubjectBaseModel.h"
#import <FSTuple.h>

@interface FSBestSubjectModel : FSBestSubjectBaseModel

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy)   NSString   *tm;    // time,时间，秒数，整型

@property (nonatomic,copy)   NSString   *nm;    // name,名称
@property (nonatomic,copy)   NSString   *be;    // belong,属性，如资产、负债、收入、成本、权益等；
@property (nonatomic,copy)   NSString   *jd;    // 增加记入借方还是贷方？1记入借方 2记入贷方；资产、成本为1，其他为2.

@property (nonatomic,copy)   NSString   *vl;    // value,科目值，从1开始，一直递增,用于表征科目 soleKey

// 非fields
@property (nonatomic,copy)   NSString   *bn;    // belong的name

// 年报科目变动额中用到
@property (nonatomic,assign)  double   sum;             // 累加值
@property (nonatomic,copy)   NSString   *sumShow;         // 累加值

@property (nonatomic,copy)   NSString   *power;         // 比例

- (void)preCount;

+ (NSArray<NSString *> *)tableFields;

@end
