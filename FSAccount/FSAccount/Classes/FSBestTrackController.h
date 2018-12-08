//
//  FSBestTrackController.h
//  myhome
//
//  Created by FudonFuchina on 2018/6/16.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"
#import "FSBestAccountModel.h"

@interface FSBestTrackController : FSBaseController

@property (nonatomic,copy) NSString                 *table;
@property (nonatomic,strong) FSBestAccountModel       *model;
@property (nonatomic,assign) NSInteger              markSubject;//1为第一个科目aj，2为第二个科目bj

@end
