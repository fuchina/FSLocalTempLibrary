//
//  FSBestAccountModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseBestAccountModel.h"
//#import "FSMacro.h"

@interface FSBestAccountModel : FSBaseBestAccountModel

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy)   NSString   *ct;    // createTime 秒数，整型

@property (nonatomic,copy)   NSString   *tm;    // time,时间，秒数，整型
@property (nonatomic,copy)   NSString   *je;    // 金额
@property (nonatomic,copy)   NSString   *bz;    // 备注
@property (nonatomic,copy)   NSString   *aj;    // A科目
@property (nonatomic,copy)   NSString   *bj;    // B科目

@property (nonatomic,copy)   NSString   *pa;    // int,1增，2减
@property (nonatomic,copy)   NSString   *pb;    // int,1增，2减
@property (nonatomic,copy)   NSString   *ar;    // A科目的剩余值
@property (nonatomic,copy)   NSString   *br;    // B科目的剩余值

+ (NSArray<NSString *> *)tableFields;

- (void)countProperties:(NSString *)subject track:(BOOL)track search:(NSString *)search table:(NSString *)table;

@end
