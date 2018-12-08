//
//  FSBestAccountCell.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBestAccountModel.h"
#import "FSBestSubjectModel.h"

@interface FSBestAccountCell : UITableViewCell

@property (nonatomic,strong) FSBestAccountModel     *model;
@property (nonatomic,copy)   NSString               *searchFlag;
@property (nonatomic,copy) void (^trackCallback)(FSBestAccountModel *bModel,NSInteger markSubject,NSString *name);

- (void)setImageHidden:(BOOL)hidden;

@end
