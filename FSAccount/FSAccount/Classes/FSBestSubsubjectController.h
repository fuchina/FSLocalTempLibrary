//
//  FSBestSubsubjectController.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/6.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSShakeBaseController.h"
#import "FSBestAccountAPI.h"

@interface FSBestSubsubjectController : FSShakeBaseController

@property (nonatomic,strong) NSString   *table;
@property (nonatomic,assign) CGFloat    sum;
@property (nonatomic,assign) CGFloat    thisYear;
@property (nonatomic,strong) NSString   *be;
@property (nonatomic,strong) NSString   *all;

@property (nonatomic,assign) BOOL       needThisYear;

@end
