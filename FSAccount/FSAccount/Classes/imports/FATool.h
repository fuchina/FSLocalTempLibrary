//
//  FATool.h
//  myhome
//
//  Created by fudon on 2017/3/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSAccountConfiger.h"

@interface FATool : NSObject

+ (NSString *)hansForShort:(NSString *)type;
+ (NSString *)hansForShort:(NSString *)type isCompany:(BOOL)isCompany;
+ (NSString *)noticeForType:(NSString *)type;

// 检查subject如sr/cb等是否包含在所有的科目表中
+ (BOOL)checkSubjectContainedInSubjects:(NSString *)subject;


/*
 1.借方：资产ing，负债ed，收入ed,成本ing；
 2.贷方：资产ed，负债ing,收入ing,成本ed；
 */
+ (BOOL)balanceCheck:(NSArray *)array;

//+ (void)copySQLData;

//+ (FSAccEntity *)accEntityGetDataFromEntity:(SQLEntity *)entity;

+ (NSArray *)debtors;
+ (NSArray *)creditors;

// 判断是否是借方或贷方,@param ysing,xjed...
+ (BOOL)isDebtor:(NSString *)type;
+ (BOOL)isCreditor:(NSString *)type;

// 检查属性值是否存在空项，返回是空值的属性
+ (NSString *)checkPropertyIsNull:(id)instance;
@end
