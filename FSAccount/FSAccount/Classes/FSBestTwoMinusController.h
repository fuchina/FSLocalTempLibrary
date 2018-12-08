//
//  FSBestTwoMinusController.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"
#import "FSBestSubjectModel.h"

@interface FSBestTwoMinusController : FSBaseController

@property (nonatomic,strong) NSArray<FSBestSubjectModel *>      *subjects;
@property (nonatomic,copy) NSString                             *table;
@property (nonatomic,copy) NSString                             *je;
@property (nonatomic,copy) NSString                             *bz;

@property (nonatomic,copy) void (^completion)(FSBestTwoMinusController *bController,Tuple2 *bResults);

@end
