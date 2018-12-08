//
//  FSBestAccountModel.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountModel.h"
#import "FSCalculator.h"
#import "FSBestAccountAPI.h"
#import "FSMacro.h"

@implementation FSBestAccountModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"ct",@"tm",@"je",@"bz",@"aj",@"bj",@"pa",@"pb",@"ar",@"br"];
}

- (void)countProperties:(NSString *)subject track:(BOOL)track search:(NSString *)search table:(NSString *)table{
    static CGFloat sw = 0;
    if (sw < 10) {
        sw = [UIScreen mainScreen].bounds.size.width;
    }
    NSInteger ap = [self.pa integerValue];
    if (ap == 1 || ap == 2) {
        FSBestSubjectModel *am = [FSBestAccountAPI subjectForValue:self.aj table:table];
        self.aType = am.nm;
        self.arColor = ap == 1?FS_TextColor_Dark:FS_TextColor_Light;
        self.atColor = FS_TextColor_Normal;
        self.aBe = am.be;
    }
    NSInteger bp = [self.pb integerValue];
    if (bp == 1 || bp == 2) {
        FSBestSubjectModel *bm = [FSBestAccountAPI subjectForValue:self.bj table:table];
        self.bType = bm.nm;
        self.brColor = bp == 1?FS_TextColor_Dark:FS_TextColor_Light;
        self.btColor = FS_TextColor_Normal;
        self.bBe = bm.be;
    }
    
    self.readableTime = [FSKit ymdhsByTimeIntervalString:self.tm];
    float height = MAX([FSCalculator textHeight:self.bz font:FONTFC(14) labelWidth:sw - 30], 44);
    self.contentHeight = height;
    self.cellHeight = height + 105;
    
    UIColor *redColor = [UIColor redColor];
    CGFloat je = [self.je doubleValue];
    NSString *jeShow = [[NSString alloc] initWithFormat:@"%.2f",je];
    if (search) {
        self.showJE = [FSKit attributedStringFor:jeShow strings:@[search] color:redColor fontStrings:nil font:nil];
    }else{
        self.showJE = [FSKit attributedStringFor:jeShow strings:@[jeShow] color:[UIColor blackColor] fontStrings:nil font:nil];
    }
    
    self.restA = [[NSString alloc] initWithFormat:@"%.2f",[self.ar doubleValue]];
    self.restB = [[NSString alloc] initWithFormat:@"%.2f",[self.br doubleValue]];
    
    /*
    如果a、b科目相同，肯定也有一个是p为2
     */
    self.bz = self.bz?:@"";
    if (subject && track) {
        NSInteger sub = [subject integerValue];
        NSInteger aj = [self.aj integerValue];
        NSInteger bj = [self.bj integerValue];
        if ([self.pa integerValue] == 1) {
            if (sub == aj) {
                CGFloat ar = [self.ar doubleValue];
                self.canClick = !(_fs_floatEqual(ar, je) || search);
                self.markSubject = 1;
            }
        }
        
        if ([self.pb integerValue] == 1){
            if (sub == bj) {
                CGFloat br = [self.br doubleValue];
                self.canClick = !(_fs_floatEqual(br, je) || search);
                self.markSubject = 2;
            }
        }
        
        static UIColor *gColor = nil;
        if (!gColor) {
            gColor = FS_GreenColor;
        }
        if (self.canClick) {
            self.colorBZ = [FSKit attributedStringFor:self.bz strings:@[self.bz] color:gColor fontStrings:nil font:nil];
        }
    }
    
    if (search){
        self.colorBZ = [FSKit attributedStringFor:self.bz strings:@[search] color:redColor fontStrings:nil font:nil];
    }
        
    if (!self.colorBZ) {
        self.colorBZ = [FSKit attributedStringFor:self.bz strings:@[self.bz] color:FS_TextColor_Normal fontStrings:nil font:nil];
    }
}

@end
