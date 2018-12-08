//
//  FSBestSubjectBaseModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSBestSubjectBaseModel : NSObject

@property (nonatomic,assign) NSInteger isp;   // 1增加，2减少

@property (nonatomic,copy) NSString     *value; // 科目对应的值
@property (nonatomic,assign) double     v;      // 科目对应的值

@property (nonatomic,strong) UIColor    *color;      // 年报科目变动数据颜色

@end
