//
//  FSABModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/22.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABBaseModel.h"

@interface FSABModel : FSABBaseModel

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString *time;      // 由于历史原因，time表示记的是哪天的账
@property (nonatomic,copy) NSString *ctime;     // 表示这条数据生成的时间
@property (nonatomic,copy) NSString *je;        // 金额

@property (nonatomic,copy) NSString *atype;     // 类型
@property (nonatomic,copy) NSString *btype;     // 类型
@property (nonatomic,copy) NSString *bz;        // 备注
@property (nonatomic,copy) NSString *arest;     // atype剩余金额
@property (nonatomic,copy) NSString *brest;     // btype剩余金额

+ (NSArray<NSString *> *)tableFields;

- (void)processPropertiesWithType:(NSString *)type search:(NSString *)search isCompany:(BOOL)isCompany;
- (void)processPropertiesWithType:(NSString *)type canSeeTrack:(BOOL)canSeeTrack search:(NSString *)search isCompany:(BOOL)isCompany;

@end
