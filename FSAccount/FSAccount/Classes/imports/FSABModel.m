//
//  FSABModel.m
//  myhome
//
//  Created by FudonFuchina on 2017/5/22.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABModel.h"
#import <FSKit.h>
#import <UIKit/UIKit.h>
#import <FSCalculator.h>
#import "FSAccountConfiger.h"
#import "FATool.h"

@implementation FSABModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"time",@"ctime",@"je",@"atype",@"btype",@"bz",@"arest",@"brest"];
}

- (void)processPropertiesWithType:(NSString *)type search:(NSString *)search isCompany:(BOOL)isCompany{
    [self processPropertiesWithType:type canSeeTrack:YES search:search isCompany:isCompany];
}

- (void)processPropertiesWithType:(NSString *)type canSeeTrack:(BOOL)canSeeTrack search:(NSString *)search isCompany:(BOOL)isCompany{
    static CGFloat sw = 0;
    if (sw < 10) {
        sw = [UIScreen mainScreen].bounds.size.width;
    }
    self.readableTime = [FSKit ymdhsByTimeIntervalString:self.time];
    float height = MAX([FSCalculator textHeight:self.bz font:[UIFont systemFontOfSize:14] labelWidth:sw - 30], 44);
    self.contentHeight = height;
    self.cellHeight = height + 105;
    
    self.type = type;
    BOOL aPlus = [self.atype hasSuffix:_ING_KEY];
    BOOL bPlus = [self.btype hasSuffix:_ING_KEY];
    CGFloat arest = [self.arest doubleValue];
    CGFloat brest = [self.brest doubleValue];
    
    BOOL isList = (type == nil); // 列表
    if (isList) {
        if (aPlus && bPlus) {
            if (_fs_floatEqual(arest, brest)) {
                self.rest = [[NSString alloc] initWithFormat:@"%.2f",arest];
            }else{
                if (_fs_floatEqual(arest,0)) {
                    self.rest = [[NSString alloc] initWithFormat:@"/%.2f",brest];
                }else if (_fs_floatEqual(brest,0)){
                    self.rest = [[NSString alloc] initWithFormat:@"%.2f/",arest];
                }else{
                    self.rest = [[NSString alloc] initWithFormat:@"%.2f/%.2f",arest,brest];                    
                }
            }
        }else{
            self.rest = [[NSString alloc] initWithFormat:@"%.2f",MAX(arest, brest)];
        }
    }else if ([type isEqualToString:self.atype]){
        self.rest = [[NSString alloc] initWithFormat:@"%.2f",arest];
    }else if ([type isEqualToString:self.btype]) {
        self.rest = [[NSString alloc] initWithFormat:@"%.2f",brest];
    }
    
    NSString *atype = [FATool hansForShort:self.atype isCompany:isCompany];
    NSString *btype = [FATool hansForShort:self.btype isCompany:isCompany];
    if (atype == nil) {
        NSAssert(atype != nil, @"atype为nil");
        return;
    }
    if (btype == nil) {
        NSAssert(btype != nil, @"btype为nil");
        return;
    }
    
    UIColor *hColor = [FSABModel heavyColor];
    UIColor *lColor = [FSABModel lightColor];
    UIColor *gColor = [FSABModel greenColor];
    UIColor *nColor = [FSABModel normalColor];
    
    NSString *sumType = [[NSString alloc] initWithFormat:@"%@ %@",atype,btype];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:sumType];
    UIColor *aColor = aPlus?hColor:lColor;
    UIColor *bColor = bPlus?hColor:lColor;
    NSRange aRange = [sumType rangeOfString:atype];
    NSRange bRange = [sumType rangeOfString:btype];
    if (aRange.location != NSNotFound && bRange.location != NSNotFound) {
        [attr addAttribute:NSForegroundColorAttributeName value:aColor range:aRange];
        [attr addAttribute:NSForegroundColorAttributeName value:bColor range:bRange];
    }
    self.typeValue = attr;
    
    CGFloat jef = [self.je doubleValue];
    BOOL hasTrack = NO;
    if (canSeeTrack) {
        if (isList) {  // 列表
            hasTrack = (aPlus && !_fs_floatEqual(arest,jef)) || (bPlus && !_fs_floatEqual(brest,jef));
        }else{
            if ([type hasSuffix:_ING_KEY]) {
                if ([type isEqualToString:self.atype] && !_fs_floatEqual(arest,jef)) {
                    hasTrack = YES;
                }
                if ([type isEqualToString:self.btype] && !_fs_floatEqual(brest,jef)) {
                    hasTrack = YES;
                }
            }
        }
    }
    BOOL enabled = hasTrack && canSeeTrack;
    self.enabled = enabled;
    
    UIColor *redColor = [FSABModel redColor];
    
    NSString *je = [[NSString alloc] initWithFormat:@"%.2f",jef];
    if (search) {
        NSString *bz = self.bz;
        NSRange range = [bz rangeOfString:search];
        if (range.location != NSNotFound) {
            NSArray *ranges = @[[NSValue valueWithRange:range]];
            NSAttributedString *attr = [FSKit attributedStringFor:bz colorRange:ranges color:redColor textRange:nil font:nil];
            self.bzText = attr;
        }
        
        NSRange mRange = [je rangeOfString:search];
        if (mRange.location != NSNotFound) {
            NSAttributedString *attr = [FSKit attributedStringFor:je colorRange:@[[NSValue valueWithRange:mRange]] color:redColor textRange:nil font:nil];
            self.money = attr;
            self.isMoneyRich = YES;
        }else{
            self.money = je;
        }
    }else{
        self.money = je;

        self.bzColor = enabled?gColor:nColor;
    }
}

+ (UIColor *)heavyColor{
    static UIColor  *hColor = nil;
    if (!hColor) {
        CGFloat rgb = 16/255.0;
        hColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];
    }
    return hColor;
}

+ (UIColor *)lightColor{
    static UIColor *lColor = nil;
    if (!lColor) {
        CGFloat rgb = 160/255.0;
        lColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];
    }
    return lColor;
}

+ (UIColor *)greenColor{
    static UIColor *gColor = nil;
    if (!gColor) {
        gColor = [UIColor colorWithRed:64/255.0 green:171/255.0 blue:62/255.0 alpha:1];
    }
    return gColor;
}

+ (UIColor *)normalColor{
    static UIColor *nColor = nil;
    if (!nColor) {
        CGFloat rgb = 88/255.0;
        nColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];
    }
    return nColor;
}

+ (UIColor *)redColor{
    static UIColor *nColor = nil;
    if (!nColor) {
        nColor = [UIColor redColor];
    }
    return nColor;
}


@end
