//
//  FSBestAccountDetailController.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/6.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSShakeBaseController.h"
#import "FSBestSubjectModel.h"

@interface FSBestAccountDetailController : FSShakeBaseController

@property (nonatomic,copy) NSString                 *table;
@property (nonatomic,copy) NSString                 *subject;
@property (nonatomic,copy) NSString                 *name;

@property (nonatomic,assign) NSInteger              start;
@property (nonatomic,assign) NSInteger              end;

@end
