//
//  FSBestSubjectModel.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestSubjectModel.h"
#import "FSBestAccountAPI.h"

@implementation FSBestSubjectModel

- (void)preCount{
    NSArray *list = [FSBestAccountAPI accountantClass];
    NSInteger be = [self.be integerValue];
    for (Tuple3 *t in list) {
        if ([t._2 integerValue] == be) {
            self.bn = t._1;
            break;
        }
    }
}

+ (NSArray<NSString *> *)tableFields{
    return @[@"tm",@"nm",@"be",@"jd",@"vl"];
}

@end
