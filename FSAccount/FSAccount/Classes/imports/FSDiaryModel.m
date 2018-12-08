//
//  FSDiaryModel.m
//  myhome
//
//  Created by FudonFuchina on 2017/5/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSDiaryModel.h"

@implementation FSDiaryModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"time",@"content",@"zone",@"saw"];
}

@end
