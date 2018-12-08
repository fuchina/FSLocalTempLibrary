//
//  FSBestOneMinusController.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"
#import "FSBestSubjectModel.h"

@interface FSBestOneMinusController : FSBaseController

@property (nonatomic,copy)   NSString                   *je;
@property (nonatomic,strong) FSBestSubjectModel         *subject;
@property (nonatomic,copy)   NSString                   *table;

@property (nonatomic,copy) void (^completion)(FSBestOneMinusController *bController,NSArray *bEdArray);

@end
