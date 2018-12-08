//
//  FSPwdBookModel.m
//  myhome
//
//  Created by FudonFuchina on 2017/8/13.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSPwdBookModel.h"

@implementation FSPwdBookModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"time",@"begin",@"name",@"login",@"pwd",@"phone",@"mail",@"note",@"zone"];
}

@end
