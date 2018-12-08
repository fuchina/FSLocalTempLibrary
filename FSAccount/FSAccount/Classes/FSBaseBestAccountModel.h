//
//  FSBaseBestAccountModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/3.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSBaseBestAccountModel : NSObject

@property (nonatomic,copy) NSString                 *arst;
@property (nonatomic,copy) NSString                 *brst;

@property (nonatomic,copy) NSString                 *readableTime;
@property (nonatomic,assign) float                  contentHeight;
@property (nonatomic,assign) float                  cellHeight;

@property (nonatomic,strong) NSAttributedString     *showJE;
@property (nonatomic,strong) NSAttributedString     *colorBZ;

@property (nonatomic,copy) NSString                 *restA;
@property (nonatomic,copy) NSString                 *restB;

@property (nonatomic,copy) NSString                 *aType;
@property (nonatomic,copy) NSString                 *bType;

@property (nonatomic,assign) BOOL                   canClick;
@property (nonatomic,assign) NSInteger              markSubject;    // 1 aj，2 bj

@property (nonatomic,copy) NSString                 *aBe;   // a科目会计属性
@property (nonatomic,copy) NSString                 *bBe;   // b科目会计属性

@property (nonatomic,assign) BOOL                   selected;

@property (nonatomic,strong) UIColor                *arColor;
@property (nonatomic,strong) UIColor                *brColor;
@property (nonatomic,strong) UIColor                *atColor;   // atype颜色
@property (nonatomic,strong) UIColor                *btColor;   // btype颜色

@property (nonatomic,assign) BOOL                   aIsFlow; // 流水中用到，如果a科目为收入或成本属性，则为YES，否则为B

@property (nonatomic,assign) NSTimeInterval         selectedTime; // 减记选中时用到，用于排序

@end
