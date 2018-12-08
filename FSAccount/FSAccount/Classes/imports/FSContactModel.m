//
//  FSContactModel.m
//  myhome
//
//  Created by FudonFuchina on 2017/5/26.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSContactModel.h"

@implementation FSContactModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"time",@"name",@"phone",@"type"];
}

@end
