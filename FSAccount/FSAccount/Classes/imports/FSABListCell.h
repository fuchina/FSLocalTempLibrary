//
//  FSABListCell.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/21.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSABModel.h"

@interface FSABListCell : UITableViewCell

@property (nonatomic,copy)   NSString       *searchFlag;
@property (nonatomic,copy) void (^trackCallback)(FSABModel *bModel,NSString *type);

@property (nonatomic,assign) NSInteger  index;
@property (nonatomic,copy) void (^heightCallback)(CGFloat h,NSInteger index);

- (void)flowConfigDataWithEntity:(FSABModel *)entity;

@end
