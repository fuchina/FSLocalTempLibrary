//
//  FSABUpdateController.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/21.
//  Copyright © 2017年 fuhope. All rights reserved.
//

/*
 账本修改逻辑:
 1.被修改科目是减少，说明肯定减少过其他数据，就不能改成增加，只能继续改成其他科目的减少；
     // 原来减少的是现金，现在改成减少应收，那么应收还得减少，而原来减少的现金又无法补回，所以有逻辑矛盾，不能执行
 
 2.被修改科目是增加：【只有这种情况可以修改】
     没有被减少过，可以改成其他科目的增加，也可以改成其他科目的减少；
 
     被减少过，可以改成其他科目的增加；
         // 会导致被改科目为负值
 */

#import "FSBaseController.h"
#import "FSABModel.h"

@interface FSABUpdateController : FSBaseController

@property (nonatomic,strong) FSABModel   *model;
@property (nonatomic,assign) BOOL         isA;
@property (nonatomic,copy) NSString      *accountName;

@property (nonatomic,copy) void (^callBack)(FSBaseController *bVC,NSString *sql);

@end
