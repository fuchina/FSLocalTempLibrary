//
//  FSBestTrackModel.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/3.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestTrackModel.h"
#import <FuSoft.h>
#import <UIKit/UIKit.h>
#import <FSCalculator.h>
#import <FSKit/FSDate.h>

@implementation FSBestTrackModel

- (void)countProperties{
    CGFloat height = [FSCalculator textHeight:self.bz font:[UIFont systemFontOfSize:14] labelWidth:WIDTHFC - 20];
    height = MAX(height, 30);
    self.bzHeight = ceil(height);
    self.height = self.bzHeight + 40;
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[self.tm doubleValue]];
    self.time = [FSDate stringWithDate:date formatter:@"yyyy-MM-dd HH:mm:ss"];
    self.jeShow = [[NSString alloc] initWithFormat:@"-%.2f",[self.je doubleValue]];
}

+ (NSArray<NSString *> *)tableFields{
    return @[@"tm",@"lk",@"ms",@"je",@"bz"];
}

@end
