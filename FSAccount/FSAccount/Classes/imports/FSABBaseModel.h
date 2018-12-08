//
//  FSABBaseModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/10/14.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAppModel.h"
#import <UIKit/UIKit.h>

@interface FSABBaseModel : FSAppModel

@property (nonatomic,copy) NSString     *arst;      // arest临时保值
@property (nonatomic,copy) NSString     *brst;      // brest临时保值

@property (nonatomic,copy) NSString     *rest;      // 剩余数据
@property (nonatomic,copy) NSString     *type;      // 使用的type
@property (nonatomic,assign) BOOL       enabled;    // 类型数据

@property (nonatomic,copy) NSMutableAttributedString    *typeValue;     // 类型数据
@property (nonatomic,copy) NSAttributedString           *bzText;        // 备注
@property (nonatomic,strong) UIColor                    *bzColor;       // 备注颜色
@property (nonatomic,copy) id                           money;          // 金额

@property (nonatomic,assign) BOOL       isMoneyRich;    // 金额是富文本

@end
