//
//  FSBestSubjectsController.h
//  myhome
//
//  Created by FudonFuchina on 2018/6/16.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"
#import "FSBestSubjectModel.h"

@interface FSBestSubjectsController : FSBaseController

@property (nonatomic,copy) NSString     *account;

@property (nonatomic,assign) BOOL               selectedMode;   // 选择模式
@property (nonatomic,strong) FSBestSubjectModel *model;
@property (nonatomic,copy) void (^selectSubject)(FSBestSubjectsController *c,FSBestSubjectModel *model);

@end
